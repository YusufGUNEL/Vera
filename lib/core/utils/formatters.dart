/// Tasarima ozel TL formati: bin ayraci nokta. Ornek: ₺347.240
String fmtTL(num value) {
  final n = value.round().abs();
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '₺${buf.toString()}';
}
