import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../services/drive_backup_service.dart';

// ── Singleton service ────────────────────────────────────────────────────────

final driveBackupServiceProvider = Provider<DriveBackupService>((ref) {
  return DriveBackupService();
});

// ── Sign-in state ────────────────────────────────────────────────────────────

enum DriveSignInStatus { unknown, signedIn, signedOut }

class DriveBackupNotifier extends StateNotifier<DriveSignInStatus> {
  final DriveBackupService _service;

  DriveBackupNotifier(this._service) : super(DriveSignInStatus.unknown) {
    _trySilentSignIn();
  }

  Future<void> _trySilentSignIn() async {
    final ok = await _service.signInSilently();
    state = ok ? DriveSignInStatus.signedIn : DriveSignInStatus.signedOut;
  }

  Future<bool> signIn() async {
    final ok = await _service.signInInteractive();
    state = ok ? DriveSignInStatus.signedIn : DriveSignInStatus.signedOut;
    return ok;
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = DriveSignInStatus.signedOut;
  }

  bool get isSignedIn => state == DriveSignInStatus.signedIn;
  String? get email => _service.signedInEmail;
}

final driveBackupProvider =
    StateNotifierProvider<DriveBackupNotifier, DriveSignInStatus>((ref) {
  final service = ref.watch(driveBackupServiceProvider);
  return DriveBackupNotifier(service);
});

// ── Restore state ─────────────────────────────────────────────────────────────

enum RestoreStatus { idle, checking, restoring, done, error, needsAuth }

class RestoreNotifier extends StateNotifier<RestoreStatus> {
  final DriveBackupService _service;
  final Ref _ref;

  RestoreNotifier(this._service, this._ref) : super(RestoreStatus.idle);

  /// Called when user explicitly taps "Restore from backup".
  /// Signs in interactively (refreshes token), then runs restore.
  Future<void> restoreWithSignIn() async {
    final ok = await _service.signInInteractive();
    if (!ok) return;
    state = RestoreStatus.idle; // reset so checkAndRestore proceeds
    await checkAndRestore();
  }

  /// Check Drive for a backup and restore if found.
  /// Safe to call on every cold start — skips if local data already exists.
  Future<void> checkAndRestore() async {
    if (state == RestoreStatus.checking || state == RestoreStatus.restoring) {
      return;
    }

    // Only restore if local Hive journal box is empty
    final box = await Hive.openBox('journal');
    if (box.isNotEmpty) return; // Local data exists — no restore needed

    if (!_service.isSignedIn) {
      final ok = await _service.signInSilently();
      if (!ok) {
        state = RestoreStatus.needsAuth;
        return;
      }
    }

    state = RestoreStatus.checking;

    final entries = await _service.restoreEntries();
    if (entries == null || entries.isEmpty) {
      state = RestoreStatus.idle;
      return;
    }

    state = RestoreStatus.restoring;

    // Write entries back to Hive
    for (final entry in entries) {
      await box.put(entry.id, entry.toJsonString());
    }

    // Download all media files
    await _service.restoreMedia();

    state = RestoreStatus.done;
  }
}

final restoreProvider =
    StateNotifierProvider<RestoreNotifier, RestoreStatus>((ref) {
  final service = ref.watch(driveBackupServiceProvider);
  return RestoreNotifier(service, ref);
});
