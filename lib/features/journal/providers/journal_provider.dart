import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';

const _boxName = 'journal';

final journalProvider =
    StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  return JournalNotifier();
});

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  late Box _box;

  JournalNotifier() : super([]) {
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

  JournalEntry? entryForDate(DateTime date) {
    final key = JournalEntry.dateKey(date);
    return state.where((e) => e.id == key).firstOrNull;
  }

  Future<void> save(JournalEntry entry) async {
    await _box.put(entry.id, entry.toJsonString());
    final others = state.where((e) => e.id != entry.id).toList();
    state = [entry, ...others]..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> delete(JournalEntry entry) async {
    // Delete associated files from disk
    for (final path in entry.photoPaths) {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
    for (final path in entry.voiceNotePaths) {
      final f = File(path);
      if (await f.exists()) await f.delete();
    }
    await _box.delete(entry.id);
    state = state.where((e) => e.id != entry.id).toList();
  }
}
