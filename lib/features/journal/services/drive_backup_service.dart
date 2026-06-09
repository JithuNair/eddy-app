import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';

import '../models/journal_entry.dart';

/// Backs up journal text + media to the user's Google Drive App Data folder.
///
/// File layout inside appDataFolder:
///   journal_entries.json   — all entries serialised as a JSON array
///   media/<basename>       — each photo / voice note by original filename
class DriveBackupService {
  static const _entriesFileName = 'journal_entries.json';
  static const _mediaFolder = 'media';

  static final _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  // ── Sign-in ───────────────────────────────────────────────────────────────

  Future<bool> signInSilently() async {
    try {
      final account = await _googleSignIn.signInSilently();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signInInteractive() async {
    try {
      final account = await _googleSignIn.signIn();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  Future<void> signOut() => _googleSignIn.signOut();

  bool get isSignedIn => _googleSignIn.currentUser != null;
  String? get signedInEmail => _googleSignIn.currentUser?.email;

  // ── Drive client ──────────────────────────────────────────────────────────

  Future<drive.DriveApi?> _driveApi() async {
    try {
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.requestScopes([drive.DriveApi.driveAppdataScope]);
      }
    } catch (_) {}
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }

  // ── Stream helper — reliable byte collection ──────────────────────────────

  /// Collects all bytes from a Drive media stream reliably.
  Future<Uint8List> _collectBytes(drive.Media media) async {
    final chunks = <List<int>>[];
    await for (final chunk in media.stream) {
      chunks.add(chunk);
    }
    final totalLength = chunks.fold<int>(0, (sum, c) => sum + c.length);
    final result = Uint8List(totalLength);
    var offset = 0;
    for (final chunk in chunks) {
      result.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return result;
  }

  // ── Backup ────────────────────────────────────────────────────────────────

  Future<void> backupAll(List<JournalEntry> entries) async {
    if (entries.isEmpty) return;
    try {
      final api = await _driveApi();
      if (api == null) return;
      await _uploadEntriesJson(api, entries);
      for (final entry in entries) {
        for (final path in [...entry.photoPaths, ...entry.voiceNotePaths]) {
          await _uploadMediaFile(api, path);
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('[DriveBackup] backupAll error: $e');
    }
  }

  Future<void> backupEntry(
      List<JournalEntry> allEntries, JournalEntry saved) async {
    if (allEntries.isEmpty) return;
    try {
      final api = await _driveApi();
      if (api == null) return;
      await _uploadEntriesJson(api, allEntries);
      for (final path in [...saved.photoPaths, ...saved.voiceNotePaths]) {
        await _uploadMediaFile(api, path);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[DriveBackup] backupEntry error: $e');
    }
  }

  Future<void> _uploadEntriesJson(
      drive.DriveApi api, List<JournalEntry> entries) async {
    final jsonBytes =
        utf8.encode(jsonEncode(entries.map((e) => e.toJson()).toList()));
    final stream = Stream.value(jsonBytes);
    final media = drive.Media(stream, jsonBytes.length,
        contentType: 'application/json');

    final existing = await _findFile(api, _entriesFileName);
    if (existing != null) {
      await api.files.update(drive.File(), existing, uploadMedia: media);
    } else {
      final meta = drive.File()
        ..name = _entriesFileName
        ..parents = ['appDataFolder'];
      await api.files.create(meta, uploadMedia: media);
    }
  }

  Future<void> _uploadMediaFile(drive.DriveApi api, String localPath) async {
    final file = File(localPath);
    if (!await file.exists()) return;

    final basename = file.uri.pathSegments.last;
    final driveName = '$_mediaFolder/$basename';

    final existing = await _findFile(api, driveName);
    if (existing != null) return; // already uploaded

    final bytes = await file.readAsBytes();
    final mimeType = _mimeType(basename.split('.').last.toLowerCase());
    final stream = Stream.value(bytes);
    final media = drive.Media(stream, bytes.length, contentType: mimeType);

    final meta = drive.File()
      ..name = driveName
      ..parents = ['appDataFolder'];
    await api.files.create(meta, uploadMedia: media);
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  Future<List<JournalEntry>?> restoreEntries() async {
    try {
      final api = await _driveApi();
      if (api == null) return null;

      final fileId = await _findFile(api, _entriesFileName);
      if (fileId == null) return null;

      final media = await api.files
          .get(fileId, downloadOptions: drive.DownloadOptions.fullMedia)
          as drive.Media;

      final bytes = await _collectBytes(media);
      if (bytes.isEmpty) return null;

      final json = jsonDecode(utf8.decode(bytes)) as List<dynamic>;
      return json
          .map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('[DriveBackup] restoreEntries error: $e');
      return null;
    }
  }

  /// Downloads all media files from Drive.
  /// Returns a map of { basename → absolute local path } for every file
  /// downloaded, so callers can rewrite stale paths in restored entries.
  Future<Map<String, String>> restoreMedia() async {
    final pathMap = <String, String>{};
    try {
      final api = await _driveApi();
      if (api == null) return pathMap;

      final appDoc = await getApplicationDocumentsDirectory();

      String? pageToken;
      do {
        final list = await api.files.list(
          spaces: 'appDataFolder',
          q: "name contains '$_mediaFolder/'",
          $fields: 'nextPageToken, files(id, name)',
          pageToken: pageToken,
        );

        for (final f in list.files ?? []) {
          final driveName = f.name ?? '';
          final basename = driveName.replaceFirst('$_mediaFolder/', '');
          if (basename.isEmpty) continue;

          final ext = basename.split('.').last.toLowerCase();
          final subDir = _isAudio(ext) ? 'voice' : 'photos';
          final localDir = Directory('${appDoc.path}/journal/$subDir');
          await localDir.create(recursive: true);

          final localFile = File('${localDir.path}/$basename');

          // Re-download if missing OR empty (a previous failed restore may
          // have created a 0-byte file — don't trust it).
          final shouldDownload =
              !await localFile.exists() || await localFile.length() == 0;

          if (shouldDownload) {
            final media = await api.files
                .get(f.id!, downloadOptions: drive.DownloadOptions.fullMedia)
                as drive.Media;

            final bytes = await _collectBytes(media);
            if (bytes.isNotEmpty) {
              await localFile.writeAsBytes(bytes, flush: true);
            }
          }

          // Track basename → local path regardless (used for path rewriting)
          pathMap[basename] = localFile.path;
        }

        pageToken = list.nextPageToken;
      } while (pageToken != null);
    } catch (e) {
      // ignore: avoid_print
      print('[DriveBackup] restoreMedia error: $e');
    }
    return pathMap;
  }

  /// Rewrites absolute paths in a restored entry to match the current device.
  /// This fixes stale paths that were serialised on a different install.
  JournalEntry rewritePaths(
      JournalEntry entry, Map<String, String> basenameToPath) {
    List<String> fix(List<String> paths) {
      return paths.map((p) {
        final basename = p.split('/').last;
        return basenameToPath[basename] ?? p;
      }).toList();
    }

    return JournalEntry(
      id: entry.id,
      date: entry.date,
      heading: entry.heading,
      subheading: entry.subheading,
      body: entry.body,
      photoPaths: fix(entry.photoPaths),
      voiceNotePaths: fix(entry.voiceNotePaths),
      musicUrl: entry.musicUrl,
      musicTitle: entry.musicTitle,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }

  // ── Momentum backup / restore ─────────────────────────────────────────────

  static const _habitsFileName = 'momentum_habits.json';

  Future<void> backupHabits(List<dynamic> habits) async {
    if (habits.isEmpty) return;
    try {
      final api = await _driveApi();
      if (api == null) return;

      // habits is List<Habit> — caller passes toJson() list to avoid importing
      // the Habit model here.
      final jsonBytes = utf8.encode(jsonEncode(habits));
      final stream = Stream.value(jsonBytes);
      final media = drive.Media(stream, jsonBytes.length,
          contentType: 'application/json');

      final existing = await _findFile(api, _habitsFileName);
      if (existing != null) {
        await api.files.update(drive.File(), existing, uploadMedia: media);
      } else {
        final meta = drive.File()
          ..name = _habitsFileName
          ..parents = ['appDataFolder'];
        await api.files.create(meta, uploadMedia: media);
      }
    } catch (e) {
      // ignore: avoid_print
      print('[DriveBackup] backupHabits error: $e');
    }
  }

  /// Returns the raw JSON list from Drive, or null if not found.
  Future<List<Map<String, dynamic>>?> restoreHabits() async {
    try {
      final api = await _driveApi();
      if (api == null) return null;

      final fileId = await _findFile(api, _habitsFileName);
      if (fileId == null) return null;

      final media = await api.files
          .get(fileId, downloadOptions: drive.DownloadOptions.fullMedia)
          as drive.Media;

      final bytes = await _collectBytes(media);
      if (bytes.isEmpty) return null;

      final json = jsonDecode(utf8.decode(bytes)) as List<dynamic>;
      return json.cast<Map<String, dynamic>>();
    } catch (e) {
      // ignore: avoid_print
      print('[DriveBackup] restoreHabits error: $e');
      return null;
    }
  }

  /// Delete a media file from Drive.
  Future<void> deleteMediaFile(String localPath) async {
    try {
      final api = await _driveApi();
      if (api == null) return;
      final basename = localPath.split('/').last;
      final driveName = '$_mediaFolder/$basename';
      final fileId = await _findFile(api, driveName);
      if (fileId != null) await api.files.delete(fileId);
    } catch (e) {
      // ignore: avoid_print
      print('[DriveBackup] deleteMediaFile error: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<String?> _findFile(drive.DriveApi api, String name) async {
    final result = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$name'",
      $fields: 'files(id)',
      pageSize: 1,
    );
    return result.files?.firstOrNull?.id;
  }

  bool _isAudio(String ext) =>
      ['m4a', 'aac', 'mp3', 'wav', 'ogg', 'opus', 'caf'].contains(ext);

  String _mimeType(String ext) {
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'heic' => 'image/heic',
      'm4a' => 'audio/mp4',
      'aac' => 'audio/aac',
      'mp3' => 'audio/mpeg',
      'wav' => 'audio/wav',
      'ogg' => 'audio/ogg',
      'opus' => 'audio/opus',
      _ => 'application/octet-stream',
    };
  }
}
