/// Converts Persian/Arabic digits and common locale-specific separators to a number.
double parseEstimateNumber(
  String raw, {
  required String label,
  bool allowZero = false,
}) {
  final normalizedDigits = String.fromCharCodes(raw.runes.map((rune) {
    if (rune >= 0x06F0 && rune <= 0x06F9) return rune - 0x06F0 + 0x30;
    if (rune >= 0x0660 && rune <= 0x0669) return rune - 0x0660 + 0x30;
    if (rune >= 0xFF10 && rune <= 0xFF19) return rune - 0xFF10 + 0x30;
    return rune;
  }));
  var normalized = normalizedDigits
      .replaceAll('٫', '.')
      .replaceAll('٬', '')
      .replaceAll(' ', '')
      .replaceAll(String.fromCharCode(0x00A0), '')
      .replaceAll(String.fromCharCode(0x200E), '')
      .replaceAll(String.fromCharCode(0x200F), '');
  if (normalized.contains(',') && normalized.contains('.')) {
    normalized = normalized.replaceAll(',', '');
  } else if (normalized.contains(',')) {
    final groups = normalized.split(',');
    final isThousands = groups.length > 1 &&
        groups.first.isNotEmpty && groups.first.length <= 3 &&
        groups.skip(1).every((group) => group.length == 3);
    normalized = isThousands ? normalized.replaceAll(',', '') : normalized.replaceAll(',', '.');
  }
  final value = double.tryParse(normalized);
  if (value == null || !value.isFinite || (allowZero ? value < 0 : value <= 0)) {
    final requirement = allowZero ? 'صفر یا عدد مثبت' : 'عدد مثبت';
    throw FormatException('مقدار «$label» باید $requirement معتبر باشد.');
  }
  return value;
}

/// Groups digits of a whole amount with the Persian thousands separator.
String groupDigits(num value) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write('٬');
    out.write(digits[i]);
  }
  return (negative ? '-' : '') + out.toString();
}

/// Persian digits for any text.
String toPersianDigits(String text) {
  const latin = '0123456789';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final ch = String.fromCharCode(rune);
    final i = latin.indexOf(ch);
    buffer.write(i < 0 ? ch : persian[i]);
  }
  return buffer.toString();
}

/// A money amount in toman with Persian digits and separators.
String formatToman(num value) => toPersianDigits(groupDigits(value));
