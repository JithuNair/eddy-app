import 'dart:convert';

class JournalEntry {
  final String id;
  final DateTime date; // normalised to midnight
  final String? heading;
  final String? subheading;
  final String? body;
  final List<String> photoPaths;
  final List<String> voiceNotePaths;
  final String? musicUrl;
  final String? musicTitle;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    required this.id,
    required this.date,
    this.heading,
    this.subheading,
    this.body,
    this.photoPaths = const [],
    this.voiceNotePaths = const [],
    this.musicUrl,
    this.musicTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmpty =>
      (heading == null || heading!.isEmpty) &&
      (subheading == null || subheading!.isEmpty) &&
      (body == null || body!.isEmpty) &&
      photoPaths.isEmpty &&
      voiceNotePaths.isEmpty &&
      musicUrl == null;

  JournalEntry copyWith({
    String? heading,
    String? subheading,
    String? body,
    List<String>? photoPaths,
    List<String>? voiceNotePaths,
    String? musicUrl,
    String? musicTitle,
    bool clearMusicUrl = false,
    bool clearMusicTitle = false,
  }) {
    return JournalEntry(
      id: id,
      date: date,
      heading: heading ?? this.heading,
      subheading: subheading ?? this.subheading,
      body: body ?? this.body,
      photoPaths: photoPaths ?? this.photoPaths,
      voiceNotePaths: voiceNotePaths ?? this.voiceNotePaths,
      musicUrl: clearMusicUrl ? null : (musicUrl ?? this.musicUrl),
      musicTitle: clearMusicTitle ? null : (musicTitle ?? this.musicTitle),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'heading': heading,
        'subheading': subheading,
        'body': body,
        'photoPaths': photoPaths,
        'voiceNotePaths': voiceNotePaths,
        'musicUrl': musicUrl,
        'musicTitle': musicTitle,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] as String,
        date: DateTime.parse(json['date'] as String),
        heading: json['heading'] as String?,
        subheading: json['subheading'] as String?,
        body: json['body'] as String?,
        photoPaths: List<String>.from(json['photoPaths'] ?? []),
        voiceNotePaths: List<String>.from(json['voiceNotePaths'] ?? []),
        musicUrl: json['musicUrl'] as String?,
        musicTitle: json['musicTitle'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  /// Creates a new entry with a unique timestamped ID: 'YYYY-MM-DD_<ms>'.
  factory JournalEntry.newEntry(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    return JournalEntry(
      id: '${dateKey(d)}_${now.millisecondsSinceEpoch}',
      date: d,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Legacy single-entry factory — preserved so old 'YYYY-MM-DD' Hive keys
  /// still load correctly after migration.
  factory JournalEntry.forDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    return JournalEntry(
      id: dateKey(d),
      date: d,
      createdAt: now,
      updatedAt: now,
    );
  }

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';

  /// Returns the 'YYYY-MM-DD' prefix for any entry ID — works for both old
  /// single-entry IDs ('2026-06-09') and new timestamped IDs ('2026-06-09_1749…').
  static String datePrefix(String id) =>
      id.length >= 10 ? id.substring(0, 10) : id;

  String toJsonString() => jsonEncode(toJson());
  factory JournalEntry.fromJsonString(String s) =>
      JournalEntry.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
