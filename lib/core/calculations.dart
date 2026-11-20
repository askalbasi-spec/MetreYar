/// محاسبات پایه متره و برآورد.
/// ورودی‌ها باید مثبت و در واحدهای ذکرشده باشند.
class MetreYarCalculations {
  const MetreYarCalculations._();

  /// حجم عضو مستطیلی بر حسب متر مکعب.
  static double concreteVolume({
    required double lengthM,
    required double widthM,
    required double heightM,
  }) {
    _requirePositive(lengthM, 'طول');
    _requirePositive(widthM, 'عرض');
    _requirePositive(heightM, 'ارتفاع');
    return lengthM * widthM * heightM;
  }

  /// وزن تقریبی میلگرد بر حسب کیلوگرم.
  /// قطر بر حسب میلی‌متر و طول کل بر حسب متر است.
  static double rebarWeightKg({
    required double diameterMm,
    required double totalLengthM,
  }) {
    _requirePositive(diameterMm, 'قطر میلگرد');
    _requirePositive(totalLengthM, 'طول میلگرد');
    return (diameterMm * diameterMm / 162) * totalLengthM;
  }

  /// مساحت مستطیل بر حسب متر مربع.
  static double rectangleArea({
    required double lengthM,
    required double widthM,
  }) {
    _requirePositive(lengthM, 'طول');
    _requirePositive(widthM, 'عرض');
    return lengthM * widthM;
  }

  static void _requirePositive(double value, String field) {
    if (!value.isFinite || value <= 0) {
      throw ArgumentError.value(value, field, 'باید عددی مثبت و معتبر باشد.');
    }
  }
}
