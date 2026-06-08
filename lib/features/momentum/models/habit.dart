import 'dart:convert';

class Habit {
  final String id;
  final String name;
  final List<String> completedDates; // yyyy-MM-dd
  final bool archived;

  const Habit({
    required this.id,
    required this.name,
    required this.completedDates,
    this.archived = false,
  });

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool isDoneOn(DateTime day) => completedDates.contains(dateKey(day));

  bool get isDoneToday => isDoneOn(DateTime.now());

  bool get isLastChance {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    return !isDoneOn(yesterday) && !isDoneOn(today);
  }

  Habit toggleDate(DateTime day) {
    final key = dateKey(day);
    final updated = List<String>.from(completedDates);
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    return Habit(id: id, name: name, completedDates: updated);
  }

  Habit copyWithName(String newName) =>
      Habit(id: id, name: newName, completedDates: completedDates,
          archived: archived);

  Habit copyWithArchived(bool value) =>
      Habit(id: id, name: name, completedDates: completedDates,
          archived: value);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'completedDates': completedDates,
        'archived': archived,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        completedDates: List<String>.from(json['completedDates'] as List),
        // default false for habits saved before this field existed
        archived: json['archived'] as bool? ?? false,
      );

  String toJsonString() => jsonEncode(toJson());

  factory Habit.fromJsonString(String s) =>
      Habit.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
