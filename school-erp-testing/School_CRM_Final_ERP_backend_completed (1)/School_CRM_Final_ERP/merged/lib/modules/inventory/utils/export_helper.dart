import 'dart:convert';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'export_stub.dart' if (dart.library.html) 'export_web.dart' as impl;

/// Triggers a file download across Web, Mobile, and Desktop platforms.
/// Returns true immediately for backwards-compatibility with synchronous callers,
/// and delegates to FileSaver in background.
bool downloadTextFile(String filename, String content) {
  try {
    impl.downloadTextFile(filename, content);
  } catch (_) {}
  try {
    final baseName = filename.endsWith('.csv')
        ? filename.substring(0, filename.length - 4)
        : filename;
    final bytes = Uint8List.fromList(utf8.encode(content));
    FileSaver.instance.saveFile(
      name: baseName,
      bytes: bytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
  } catch (e) {
    debugPrint('downloadTextFile FileSaver error: $e');
  }
  return true;
}

/// Async version for callers that await file download completion
Future<bool> downloadTextFileAsync(String filename, String content) async {
  try {
    final baseName = filename.endsWith('.csv')
        ? filename.substring(0, filename.length - 4)
        : filename;
    final bytes = Uint8List.fromList(utf8.encode(content));
    await FileSaver.instance.saveFile(
      name: baseName,
      bytes: bytes,
      ext: 'csv',
      mimeType: MimeType.csv,
    );
    return true;
  } catch (e) {
    debugPrint('downloadTextFileAsync error: $e');
    return false;
  }
}
