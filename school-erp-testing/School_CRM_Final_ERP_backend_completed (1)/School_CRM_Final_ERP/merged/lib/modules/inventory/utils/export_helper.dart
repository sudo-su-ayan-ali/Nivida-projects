import 'export_stub.dart' if (dart.library.html) 'export_web.dart' as impl;

/// Triggers a browser file download of [content] as [filename] when running
/// on Flutter Web. On other platforms (mobile/desktop) this is a safe no-op
/// — callers should pair it with a SnackBar so the user still gets feedback,
/// since this project is frontend-only with no file-system/backend access.
bool downloadTextFile(String filename, String content) {
  return impl.downloadTextFile(filename, content);
}
