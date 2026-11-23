/// Western digits to Persian digits.
String fa(Object value) {
  const latin = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  var out = value.toString();
  for (var i = 0; i < 10; i++) {
    out = out.replaceAll(latin[i], persian[i]);
  }
  return out;
}

/// 1234567 -> ۱٬۲۳۴٬۵۶۷
String faMoney(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('٬');
    buffer.write(digits[i]);
  }
  return '${negative ? '-' : ''}${fa(buffer)}';
}

/// Reads a number typed with Persian, Arabic or Latin digits and any
/// thousands separators. Returns null when nothing usable was typed.
double? parseNumber(String input) {
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  final out = StringBuffer();
  for (final rune in input.runes) {
    final ch = String.fromCharCode(rune);
    final p = persian.indexOf(ch);
    final a = arabic.indexOf(ch);
    if (p >= 0) {
      out.write(p);
    } else if (a >= 0) {
      out.write(a);
    } else if ('0123456789.'.contains(ch)) {
      out.write(ch);
    } else if (ch == '/' || ch == '٫') {
      out.write('.');
    }
  }
  final text = out.toString();
  if (text.isEmpty) return null;
  return double.tryParse(text);
}
