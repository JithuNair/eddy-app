import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

const _boxName = 'habits';
const _seedHabitId = 'movement';

class MomentumNotifier extends StateNotifier<List<Habit>> {
  late Box _box;

  MomentumNotifier() : super([]) {
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

  void deleteHabit(String habitId) {
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
  return MomentumNotifier();
});
