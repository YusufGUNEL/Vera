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
