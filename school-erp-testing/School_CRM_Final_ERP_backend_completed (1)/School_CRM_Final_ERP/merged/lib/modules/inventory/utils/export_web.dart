// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Web implementation: builds a Blob from [content] and triggers a real
/// browser download named [filename].
bool downloadTextFile(String filename, String content) {
  final blob = html.Blob([content], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
  return true;
}
