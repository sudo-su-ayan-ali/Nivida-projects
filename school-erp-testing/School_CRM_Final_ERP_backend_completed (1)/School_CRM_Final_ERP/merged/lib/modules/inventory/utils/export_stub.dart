/// Non-web fallback: there's no filesystem/download API available in this
/// frontend-only demo for mobile/desktop targets, so this simply reports
/// that no file was written. The calling widget shows a SnackBar either way.
bool downloadTextFile(String filename, String content) {
  return false;
}
