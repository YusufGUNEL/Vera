/// Design-specific TL format with dot thousands separators.
/// Amount comes first, currency suffix last (Turkish convention: "1.234 TL").
String fmtTL(num value) {
  final n = value.round().abs();
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '${buf.toString()} TL';
}

/// Signed TL format with sign first and currency suffix last.
/// Examples: "+1.250 TL", "-420 TL".
String fmtSignedTL(
  num value, {
  bool showPlus = true,
}) {
  final rounded = value.round();
  if (rounded == 0) {
    return showPlus ? '+${fmtTL(0)}' : fmtTL(0);
  }
  final sign = rounded > 0 ? (showPlus ? '+' : '') : '-';
  return '$sign${fmtTL(rounded.abs())}';
}

String fmtShortDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year.toString();
  return '$day.$month.$year';
}
