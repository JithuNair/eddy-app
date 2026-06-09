import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _settingsBox = 'journal_settings';
const _lockEnabledKey = 'lock_enabled';

/// Whether biometric lock is enabled (user preference)
final journalLockEnabledProvider =
    StateNotifierProvider<JournalLockEnabledNotifier, bool>((ref) {
  return JournalLockEnabledNotifier();
});

class JournalLockEnabledNotifier extends StateNotifier<bool> {
  late Box _box;

  JournalLockEnabledNotifier() : super(false) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(_settingsBox);
    state = _box.get(_lockEnabledKey, defaultValue: false) as bool;
  }

  Future<void> setEnabled(bool value) async {
    await _box.put(_lockEnabledKey, value);
    state = value;
  }
}

/// Whether the journal is currently unlocked for this session
final journalUnlockedProvider =
    StateNotifierProvider<JournalUnlockedNotifier, bool>((ref) {
  return JournalUnlockedNotifier();
});

class JournalUnlockedNotifier extends StateNotifier<bool> {
  final _auth = LocalAuthentication();

  JournalUnlockedNotifier() : super(false);

  Future<bool> authenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      if (!canCheck && !isDeviceSupported) {
        // Device has no biometrics — unlock anyway
        state = true;
        return true;
      }
      final authenticated = await _auth.authenticate(
        localizedReason: 'Unlock your Journal',
        options: const AuthenticationOptions(
          biometricOnly: false, // allow PIN fallback
          stickyAuth: true,
        ),
      );
      state = authenticated;
      return authenticated;
    } catch (_) {
      state = true; // fail-open if local_auth errors
      return true;
    }
  }

  void lock() => state = false;
}
