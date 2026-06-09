import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';
import '../services/drive_backup_service.dart';
import 'drive_backup_provider.dart';

const _boxName = 'journal';

final journalProvider =
    StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  return JournalNotifier(ref);
});

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  late Box _box;
  final Ref _ref;

  JournalNotifier(this._ref) : super([]) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(_boxName);
    final entries = _box.values
        .map((v) => JournalEntry.fromJsonString(v as String))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // newest first
    state = entries;
  }

  /// All entries for a given calendar day, newest first.
  List<JournalEntry> entriesForDate(DateTime date) {
    final prefix = JournalEntry.dateKey(date);
    return state
        .where((e) => JournalEntry.datePrefix(e.id) == prefix)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  JournalEntry? entryById(String id) =>
      state.where((e) => e.id == id).firstOrNull;

  Future<void> save(JournalEntry entry) async {
    await _box.put(entry.id, entry.toJsonString());
    final others = state.where((e) => e.id != entry.id).toList();
    state = [entry, ...others]..sort((a, b) => b.date.compareTo(a.date));

    // Backup to Drive in the background (fire-and-forget)
    _driveService.backupEntry(state, entry);
  }

  Future<void> delete(JournalEntry entry) async {
    // Delete associated files from disk + queue Drive deletion
    for (final path in entry.photoPaths) {
      final f = File(path);
      if (await f.exists()) await f.delete();
      _driveService.deleteMediaFile(path);
    }
    for (final path in entry.voiceNotePaths) {
      final f = File(path);
      if (await f.exists()) await f.delete();
      _driveService.deleteMediaFile(path);
    }
    await _box.delete(entry.id);
    state = state.where((e) => e.id != entry.id).toList();

    // Update Drive entries JSON after deletion
    _driveService.backupAll(state);
  }

  DriveBackupService get _driveService =>
      _ref.read(driveBackupServiceProvider);
}
