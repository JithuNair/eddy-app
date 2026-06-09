import 'dart:convert';

class JournalEntry {
  final String id;
  final DateTime date; // normalised to midnight — one entry per day
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

  factory JournalEntry.forDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    return JournalEntry(
      id: '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}',
      date: d,
      createdAt: now,
      updatedAt: now,
    );
  }

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';

  String toJsonString() => jsonEncode(toJson());
  factory JournalEntry.fromJsonString(String s) =>
      JournalEntry.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
