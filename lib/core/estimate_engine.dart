import 'dart:math' as math;

/// The numeric core of every quick estimate. [v] reads one input by key and
/// throws a [FormatException] when it is missing or invalid.
String computeEstimate(
  int id,
  double Function(String key, {bool allowZero}) v, {
  String resultUnit = '',
}) {
  String result;
      switch (id) {
        case 51:
          result = '${(v('length') * v('width') * v('height')).toStringAsFixed(3)} مترمکعب بتن';
          break;
        case 52:
          result = '${(v('diameter') * v('diameter') / 162 * v('length')).toStringAsFixed(2)} کیلوگرم میلگرد';
          break;
        case 53:
          result = '${(v('length') * v('width')).toStringAsFixed(2)} مترمربع';
          break;
        case 1:
          result = '${(v('diameter') * v('diameter') / 162 * v('length')).toStringAsFixed(2)} کیلوگرم';
        case 2:
        case 4:
        case 7:
        case 19:
          result = id == 7
              ? (v('area') * v('rate')).ceil().toString()
              : (v('area') * v('rate')).toStringAsFixed(2);
          if (id == 2 || id == 4) {
            final kg = v('area') * v('rate');
            result = '${kg.toStringAsFixed(1)} کیلوگرم (حدود ${(kg / 1000).toStringAsFixed(3)} تن)';
          }
          if (id == 7) result += ' عدد آجر';
          if (id == 19) result += ' واحد ماده';
          break;
        case 3:
          result = '${(v('volume') * v('rate')).toStringAsFixed(2)} کیلوگرم';
        case 8:
          final mortar = v('wall') * v('factor');
          final cement = mortar * v('cement');
          final sand = mortar * v('sand');
          result = 'ملات: ${mortar.toStringAsFixed(3)} مترمکعب\nسیمان: ${cement.toStringAsFixed(1)} کیلوگرم\nماسه: ${sand.toStringAsFixed(1)} کیلوگرم';
        case 9:
        case 10:
          result = '${(v('area') * v('thickness') / 100).toStringAsFixed(3)} مترمکعب';
        case 13:
          result = '${(math.pi * math.pow(v('diameter') / 2, 2) * v('height')).toStringAsFixed(3)} مترمکعب';
          break;

        case 21:
          result = 'فرغون: ${(v('volume') * 1000 / v('wheel')).ceil()} بار\nمیکسر: ${(v('volume') * 1000 / v('mixer')).ceil()} نوبت کامل';
          break;
        case 22:
          final bank = v('length') * v('width') * v('depth');
          final loose = bank * v('factor');
          result = 'حجم درجا: ${bank.toStringAsFixed(2)} مترمکعب\nحجم با تورم: ${loose.toStringAsFixed(2)} مترمکعب\nکامیون: ${(loose / v('truck')).ceil()} سرویس';
          break;
        case 23:
        case 25:
        case 26:
        case 28:
        case 29:
        case 30:
        case 31:
        case 38:
        case 39:
          final amount = v('area') * v('rate');
          if (id == 30) {
            result = '${amount.ceil()} عدد بلوک سقفی';
          } else {
            result = '${amount.toStringAsFixed(2)} ${resultUnit}';
          }
          break;
        case 40:
          final dryMaterialKg = v('volume') * v('rate');
          result = '${dryMaterialKg.toStringAsFixed(1)} کیلوگرم مصالح خشک (حدود ${(dryMaterialKg / 1000).toStringAsFixed(3)} تن)';
          break;
        case 24:
          result = 'مصالح سنگی کل: ${(v('volume') * v('total')).toStringAsFixed(1)} کیلوگرم\nشن: ${(v('volume') * v('gravel')).toStringAsFixed(2)} مترمکعب\nماسه: ${(v('volume') * v('sand')).toStringAsFixed(2)} مترمکعب';
          break;
        case 32:
          final eff = v('slab') - v('deck') / 2;
          if (eff <= 0) throw const FormatException('ضخامت مؤثر بتن باید مثبت باشد.');
          result = 'ورق با پرت: ${(v('area') * (1 + v('waste', allowZero: true) / 100)).toStringAsFixed(2)} مترمربع\nبتن: ${(v('area') * eff).toStringAsFixed(3)} مترمکعب';
          break;
        case 33:
          result = 'قالب: ${(v('area') / v('module') * (1 + v('waste', allowZero: true) / 100)).ceil()} عدد\nبتن: ${(v('area') * v('thickness')).toStringAsFixed(3)} مترمکعب';
          break;
        case 34:
          result = '${(v('wall') * v('factor')).toStringAsFixed(3)} مترمکعب ملات';
          break;
        case 35:
          result = 'سیمان: ${(v('volume') * v('cement')).toStringAsFixed(1)} کیلوگرم\nماسه: ${(v('volume') * v('sand')).toStringAsFixed(1)} کیلوگرم';
          break;
        case 36:
          result = '${(v('volume') * v('rate')).ceil()} عدد آجر';
          break;
        case 37:
          final net = v('area') - v('openings', allowZero: true);
          if (net <= 0) throw const FormatException('مساحت خالص دیوار باید مثبت باشد.');
          result = '${(net / v('block') * (1 + v('waste', allowZero: true) / 100)).ceil()} عدد بلوک';
          break;
        case 41:
        case 42:
          result = '${(v('area') / v('coverage') * (1 + v('waste', allowZero: true) / 100)).ceil()} کیسه ۴۰ کیلویی';
          break;
        case 43:
          result = 'ورق: ${(v('area') * (1 + v('waste', allowZero: true) / 100)).toStringAsFixed(2)} مترمربع\nپیچ: ${(v('area') * v('screws')).ceil()} عدد\nشاخص طول سازه فرعی: ${(v('area') * 100 / v('spacing')).toStringAsFixed(1)} متر';
          break;
        case 44:
        case 45:
          final extra = id == 44 ? v('waste', allowZero: true) : v('extra', allowZero: true);
          result = '${(v('area') * v('coats') / v('coverage') * (1 + extra / 100)).toStringAsFixed(2)} کیلوگرم رنگ';
          break;
        case 46:
          result = 'کارتن آجر ال: ${(v('area') / v('carton')).ceil()}\nکیسه بندکشی: ${(v('area') / v('mortar')).ceil()}';
          break;
        case 47:
          result = '${(v('area') * (1 + v('waste', allowZero: true) / 100)).toStringAsFixed(2)} مترمربع سفارش';
          break;
        case 48:
          final watts = v('area') * v('rate');
          result = 'بار گرمایشی: ${watts.toStringAsFixed(0)} وات\nپره رادیاتور: ${(watts / v('fin')).ceil()} عدد';
          break;
        case 49:
          result = 'آب سرد و گرم: ${(v('area') * v('waterRate')).toStringAsFixed(1)} متر\nفاضلاب، باران و هواکش: ${(v('area') * v('drainRate')).toStringAsFixed(1)} متر';
          break;
        case 50:
          result = 'طول سیم: ${(v('area') * v('rate')).toStringAsFixed(1)} متر\nکلید و پریز: ${v('points').ceil()} عدد';
          break;
        case 20:
          final asphaltKg = v('area') * v('thickness') / 100 * v('density');
          final tiles = (v('area') / v('tileArea') * (1 + v('waste', allowZero: true) / 100)).ceil();
          result = 'آسفالت: ${asphaltKg.toStringAsFixed(1)} کیلوگرم\nکاشی/سرامیک با پرت: $tiles عدد';
        default:
          throw const FormatException('برای این مورد محاسبه عددی تعریف نشده است.');
      }
  return result;
}
