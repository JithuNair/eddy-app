import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../../journal/providers/drive_backup_provider.dart';

const _boxName = 'habits';
const _seedHabitId = 'movement';

class MomentumNotifier extends StateNotifier<List<Habit>> {
  late Box _box;
  final Ref _ref;

  MomentumNotifier(this._ref) : super([]) {
    _load();
  }

  void _load() {
    _box = Hive.box(_boxName);
    final raw = _box.values.cast<String>().toList();
    if (raw.isEmpty) {
      const seed = Habit(
        id: _seedHabitId,
        name: '30 mins of movement',
        completedDates: [],
      );
      _box.put(seed.id, seed.toJsonString());
      state = [seed];
    } else {
      state = raw.map(Habit.fromJsonString).toList();
    }
  }

  void _save(List<Habit> habits) {
    for (final h in habits) {
      _box.put(h.id, h.toJsonString());
    }
    state = habits;
    // Backup to Drive in the background (fire-and-forget)
    _ref.read(driveBackupServiceProvider)
        .backupHabits(habits.map((h) => h.toJson()).toList());
  }

  void toggleToday(String habitId) {
    final updated = state.map((h) {
      if (h.id != habitId) return h;
      return h.toggleDate(DateTime.now());
    }).toList();
    _save(updated);
  }

  void addHabit(String name) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final habit = Habit(id: id, name: name, completedDates: []);
    _save([...state, habit]);
  }

  /// Soft-delete: hides the habit from the Momentum list but preserves
  /// all history so the user can review it (and permanently wipe it) in
  /// the Tracker screen.
  void deleteHabit(String habitId) {
    final updated = state.map((h) {
      if (h.id != habitId) return h;
      return h.copyWithArchived(true);
    }).toList();
    _save(updated);
  }

  /// Restore: un-archives a habit so it reappears on the Momentum screen.
  void restoreHabit(String habitId) {
    final updated = state.map((h) {
      if (h.id != habitId) return h;
      return h.copyWithArchived(false);
    }).toList();
    _save(updated);
  }

  /// Hard-delete: permanently removes the habit and all its history from
  /// Hive. Called only from the Tracker screen via an explicit confirmation.
  void permanentlyDeleteHabit(String habitId) {
    _box.delete(habitId);
    state = state.where((h) => h.id != habitId).toList();
  }

  void renameHabit(String habitId, String newName) {
    final updated = state.map((h) {
      if (h.id != habitId) return h;
      return h.copyWithName(newName);
    }).toList();
    _save(updated);
  }
}

final momentumProvider =
    StateNotifierProvider<MomentumNotifier, List<Habit>>((ref) {
  return MomentumNotifier(ref);
});
