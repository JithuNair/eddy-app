import 'dart:convert';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';

import '../models/journal_entry.dart';

/// Backs up journal text + media to the user's Google Drive App Data folder.
///
/// The App Data folder is:
///   • Hidden from the user's Drive UI
///   • Only accessible by this app
///   • No size limit (unlike Android Auto Backup's 25 MB cap)
///   • Automatically deleted if the user revokes app access
///
/// File layout inside appDataFolder:
///   journal_entries.json        — all entries serialised as a JSON array
///   media/<basename>            — each photo / voice note by original filename
class DriveBackupService {
  static const _entriesFileName = 'journal_entries.json';
  static const _mediaFolder = 'media';

  static final _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  // ── Sign-in ──────────────────────────────────────────────────────────────

  /// Silent sign-in; returns true if the user is (or becomes) signed in.
  /// Does NOT show a UI — call [signInInteractive] when silent fails.
  Future<bool> signInSilently() async {
    try {
      final account = await _googleSignIn.signInSilently();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  /// Interactive sign-in — shows the account picker.
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
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }

  // ── Backup ────────────────────────────────────────────────────────────────

  /// Full backup: entries JSON + any media files not yet uploaded.
  /// Fire-and-forget safe — errors are swallowed and reported to console.
  Future<void> backupAll(List<JournalEntry> entries) async {
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

  /// Incremental backup after a single save — entries JSON + new media only.
  Future<void> backupEntry(
      List<JournalEntry> allEntries, JournalEntry saved) async {
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

  /// Upload the entries JSON (creates or replaces the file).
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

  /// Upload a single media file (skips if an identical-name file already exists).
  Future<void> _uploadMediaFile(drive.DriveApi api, String localPath) async {
    final file = File(localPath);
    if (!await file.exists()) return;

    final basename = file.uri.pathSegments.last;
    final driveName = '$_mediaFolder/$basename';

    final existing = await _findFile(api, driveName);
    if (existing != null) return; // already uploaded

    final bytes = await file.readAsBytes();
    final stream = Stream.value(bytes);
    final media = drive.Media(stream, bytes.length);

    final meta = drive.File()
      ..name = driveName
      ..parents = ['appDataFolder'];
    await api.files.create(meta, uploadMedia: media);
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  /// Returns all journal entries from Drive, or null if nothing found.
  Future<List<JournalEntry>?> restoreEntries() async {
    try {
      final api = await _driveApi();
      if (api == null) return null;

      final fileId = await _findFile(api, _entriesFileName);
      if (fileId == null) return null;

      final media = await api.files
          .get(fileId, downloadOptions: drive.DownloadOptions.fullMedia)
          as drive.Media;

      final bytes = <int>[];
      await media.stream.forEach(bytes.addAll);
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

  /// Downloads all media files from Drive into local journal directories.
  /// Returns the number of files restored.
  Future<int> restoreMedia() async {
    try {
      final api = await _driveApi();
      if (api == null) return 0;

      final appDoc = await getApplicationDocumentsDirectory();
      int count = 0;

      // List all appDataFolder files with name starting with 'media/'
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

          // Determine local sub-folder from extension
          final ext = basename.split('.').last.toLowerCase();
          final subDir = _isAudio(ext) ? 'voice' : 'photos';
          final localDir = Directory('${appDoc.path}/journal/$subDir');
          await localDir.create(recursive: true);

          final localFile = File('${localDir.path}/$basename');
          if (await localFile.exists()) continue; // already present

          final media = await api.files
              .get(f.id!, downloadOptions: drive.DownloadOptions.fullMedia)
              as drive.Media;

          final bytes = <int>[];
          await media.stream.forEach(bytes.addAll);
          await localFile.writeAsBytes(bytes);
          count++;
        }

        pageToken = list.nextPageToken;
      } while (pageToken != null);

      return count;
    } catch (e) {
      // ignore: avoid_print
      print('[DriveBackup] restoreMedia error: $e');
      return 0;
    }
  }

  /// Delete media file from Drive when an entry is deleted locally.
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

  /// Returns the Drive file ID if a file with [name] exists, else null.
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
}
