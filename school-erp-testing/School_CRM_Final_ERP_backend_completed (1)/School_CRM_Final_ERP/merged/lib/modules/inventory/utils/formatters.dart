/// Formats a number using the Indian numbering system
/// (e.g. 1875600 -> "18,75,600"), used for currency and quantity display.
String formatIndianNumber(num value) {
  final isNegative = value < 0;
  final intPart = value.abs().round().toString();

  String result;
  if (intPart.length <= 3) {
    result = intPart;
  } else {
    final last3 = intPart.substring(intPart.length - 3);
    var remaining = intPart.substring(0, intPart.length - 3);
    final groups = <String>[];
    while (remaining.length > 2) {
      groups.insert(0, remaining.substring(remaining.length - 2));
      remaining = remaining.substring(0, remaining.length - 2);
    }
    if (remaining.isNotEmpty) groups.insert(0, remaining);
    result = '${groups.join(',')},$last3';
  }
  return isNegative ? '-$result' : result;
}

/// Returns today's date formatted like the rest of the dashboard's dummy
/// data, e.g. "12 Aug 2026".
String todayLabel() {
  final now = DateTime.now();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${now.day} ${months[now.month - 1]} ${now.year}';
}
