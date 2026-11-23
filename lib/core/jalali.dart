import 'format.dart';

const jalaliMonthNames = [
  'فروردین',
  'اردیبهشت',
  'خرداد',
  'تیر',
  'مرداد',
  'شهریور',
  'مهر',
  'آبان',
  'آذر',
  'دی',
  'بهمن',
  'اسفند',
];

/// A date in the Persian (Jalali) calendar. Conversion uses the common
/// 33-year arithmetic algorithm, which agrees with the official calendar
/// for the years this app is used (about 1300 to 1500).
class Jalali implements Comparable<Jalali> {
  const Jalali(this.year, this.month, this.day);

  factory Jalali.fromDate(DateTime date) {
    final gy = date.year;
    final gm = date.month;
    final gd = date.day;
    const cumulative = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
    final gy2 = gm > 2 ? gy + 1 : gy;
    var days = 355666 +
        (365 * gy) +
        ((gy2 + 3) ~/ 4) -
        ((gy2 + 99) ~/ 100) +
        ((gy2 + 399) ~/ 400) +
        gd +
        cumulative[gm - 1];
    var jy = -1595 + (33 * (days ~/ 12053));
    days %= 12053;
    jy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      jy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }
    final int jm;
    final int jd;
    if (days < 186) {
      jm = 1 + days ~/ 31;
      jd = 1 + days % 31;
    } else {
      jm = 7 + (days - 186) ~/ 30;
      jd = 1 + (days - 186) % 30;
    }
    return Jalali(jy, jm, jd);
  }

  factory Jalali.today() => Jalali.fromDate(DateTime.now());

  final int year;
  final int month;
  final int day;

  /// The same day as a UTC [DateTime] (no time-zone or daylight-saving
  /// surprises when counting days).
  DateTime toDate() {
    final jy = year + 1595;
    var days = -355668 +
        (365 * jy) +
        ((jy ~/ 33) * 8) +
        (((jy % 33) + 3) ~/ 4) +
        day +
        (month < 7 ? (month - 1) * 31 : ((month - 7) * 30) + 186);
    var gy = 400 * (days ~/ 146097);
    days %= 146097;
    if (days > 36524) {
      days -= 1;
      gy += 100 * (days ~/ 36524);
      days %= 36524;
      if (days >= 365) days += 1;
    }
    gy += 4 * (days ~/ 1461);
    days %= 1461;
    if (days > 365) {
      gy += (days - 1) ~/ 365;
      days = (days - 1) % 365;
    }
    var gd = days + 1;
    final leap = (gy % 4 == 0 && gy % 100 != 0) || gy % 400 == 0;
    final lengths = [0, 31, leap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    var gm = 0;
    while (gm < 13 && gd > lengths[gm]) {
      gd -= lengths[gm];
      gm++;
    }
    return DateTime.utc(gy, gm, gd);
  }

  static bool isLeapYear(int year) =>
      const Jalali(0, 1, 1)._daysBetweenYears(year) == 366;

  int _daysBetweenYears(int y) =>
      Jalali(y + 1, 1, 1).toDate().difference(Jalali(y, 1, 1).toDate()).inDays;

  static int monthLength(int year, int month) {
    if (month <= 6) return 31;
    if (month <= 11) return 30;
    return isLeapYear(year) ? 30 : 29;
  }

  /// Adds [months], keeping the day (or the last day of a shorter month).
  Jalali addMonths(int months) {
    final total = year * 12 + (month - 1) + months;
    final y = total ~/ 12;
    final m = total % 12 + 1;
    final d = day <= monthLength(y, m) ? day : monthLength(y, m);
    return Jalali(y, m, d);
  }

  /// Whole days from [other] to this date (negative when earlier).
  int daysSince(Jalali other) => toDate().difference(other.toDate()).inDays;

  String format() =>
      '${fa(year)}/${fa(month.toString().padLeft(2, '0'))}/${fa(day.toString().padLeft(2, '0'))}';

  String formatLong() => '${fa(day)} ${jalaliMonthNames[month - 1]} ${fa(year)}';

  String toStorage() => '$year-$month-$day';

  static Jalali? fromStorage(String text) {
    final parts = text.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    if (m < 1 || m > 12 || d < 1 || d > 31) return null;
    return Jalali(y, m, d);
  }

  @override
  int compareTo(Jalali other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is Jalali &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => format();
}
