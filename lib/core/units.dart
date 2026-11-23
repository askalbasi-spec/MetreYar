/// Unit conversion for the whole app. Every category has a base unit and a
/// factor per unit (value in base = value × factor). Temperature is the
/// only category that needs an offset, so it is handled separately.
class UnitDef {
  const UnitDef(this.key, this.name, this.factor);
  final String key;
  final String name;

  /// Size of one of this unit in the category's base unit.
  final double factor;
}

class UnitCategory {
  const UnitCategory(this.name, this.units, {this.isTemperature = false});
  final String name;
  final List<UnitDef> units;
  final bool isTemperature;

  UnitDef unit(String key) => units.firstWhere((u) => u.key == key);
}

const unitCategories = <UnitCategory>[
  UnitCategory('طول', [
    UnitDef('m', 'متر (m)', 1),
    UnitDef('cm', 'سانتی‌متر (cm)', 0.01),
    UnitDef('mm', 'میلی‌متر (mm)', 0.001),
    UnitDef('km', 'کیلومتر (km)', 1000),
    UnitDef('in', 'اینچ (in)', 0.0254),
    UnitDef('ft', 'فوت (ft)', 0.3048),
    UnitDef('yd', 'یارد (yd)', 0.9144),
    UnitDef('mi', 'مایل (mi)', 1609.344),
  ]),
  UnitCategory('مساحت', [
    UnitDef('m2', 'مترمربع (m²)', 1),
    UnitDef('cm2', 'سانتی‌مترمربع (cm²)', 0.0001),
    UnitDef('mm2', 'میلی‌مترمربع (mm²)', 0.000001),
    UnitDef('km2', 'کیلومترمربع (km²)', 1000000),
    UnitDef('ha', 'هکتار (ha)', 10000),
    UnitDef('ft2', 'فوت‌مربع (ft²)', 0.09290304),
    UnitDef('in2', 'اینچ‌مربع (in²)', 0.00064516),
    UnitDef('ac', 'اکر (acre)', 4046.8564224),
  ]),
  UnitCategory('حجم', [
    UnitDef('m3', 'مترمکعب (m³)', 1),
    UnitDef('L', 'لیتر (L)', 0.001),
    UnitDef('mL', 'میلی‌لیتر (mL)', 0.000001),
    UnitDef('cm3', 'سانتی‌مترمکعب (cm³)', 0.000001),
    UnitDef('ft3', 'فوت‌مکعب (ft³)', 0.028316846592),
    UnitDef('in3', 'اینچ‌مکعب (in³)', 0.000016387064),
    UnitDef('gal', 'گالن آمریکا (gal)', 0.003785411784),
  ]),
  UnitCategory('جرم', [
    UnitDef('kg', 'کیلوگرم (kg)', 1),
    UnitDef('g', 'گرم (g)', 0.001),
    UnitDef('t', 'تن (t)', 1000),
    UnitDef('lb', 'پوند (lb)', 0.45359237),
    UnitDef('oz', 'اونس (oz)', 0.028349523125),
  ]),
  UnitCategory('نیرو', [
    UnitDef('N', 'نیوتن (N)', 1),
    UnitDef('kN', 'کیلونیوتن (kN)', 1000),
    UnitDef('kgf', 'کیلوگرم‌نیرو (kgf)', 9.80665),
    UnitDef('tf', 'تن‌نیرو (tf)', 9806.65),
    UnitDef('lbf', 'پوند‌نیرو (lbf)', 4.4482216152605),
  ]),
  UnitCategory('فشار و تنش', [
    UnitDef('Pa', 'پاسکال (Pa)', 1),
    UnitDef('kPa', 'کیلوپاسکال (kPa)', 1000),
    UnitDef('MPa', 'مگاپاسکال (MPa)', 1000000),
    UnitDef('bar', 'بار (bar)', 100000),
    UnitDef('atm', 'اتمسفر (atm)', 101325),
    UnitDef('psi', 'پوند بر اینچ‌مربع (psi)', 6894.757293168),
    UnitDef('kgfcm2', 'کیلوگرم بر سانتی‌مترمربع (kgf/cm²)', 98066.5),
  ]),
  UnitCategory('سرعت', [
    UnitDef('ms', 'متر بر ثانیه (m/s)', 1),
    UnitDef('kmh', 'کیلومتر بر ساعت (km/h)', 1 / 3.6),
    UnitDef('mph', 'مایل بر ساعت (mph)', 0.44704),
    UnitDef('kn', 'گره دریایی (kn)', 0.514444444444),
    UnitDef('fts', 'فوت بر ثانیه (ft/s)', 0.3048),
  ]),
  UnitCategory('دما', [
    UnitDef('C', 'سانتی‌گراد (°C)', 1),
    UnitDef('F', 'فارنهایت (°F)', 1),
    UnitDef('K', 'کلوین (K)', 1),
  ], isTemperature: true),
  UnitCategory('زاویه', [
    UnitDef('deg', 'درجه (°)', 1),
    UnitDef('rad', 'رادیان (rad)', 57.29577951308232),
    UnitDef('grad', 'گراد (gon)', 0.9),
  ]),
  UnitCategory('زمان', [
    UnitDef('s', 'ثانیه (s)', 1),
    UnitDef('min', 'دقیقه (min)', 60),
    UnitDef('h', 'ساعت (h)', 3600),
    UnitDef('d', 'روز (d)', 86400),
  ]),
  UnitCategory('انرژی', [
    UnitDef('J', 'ژول (J)', 1),
    UnitDef('kJ', 'کیلوژول (kJ)', 1000),
    UnitDef('kWh', 'کیلووات‌ساعت (kWh)', 3600000),
    UnitDef('kcal', 'کیلوکالری (kcal)', 4184),
    UnitDef('BTU', 'بی‌تی‌یو (BTU)', 1055.05585262),
  ]),
  UnitCategory('توان', [
    UnitDef('W', 'وات (W)', 1),
    UnitDef('kW', 'کیلووات (kW)', 1000),
    UnitDef('hp', 'اسب‌بخار (hp)', 745.69987158227),
    UnitDef('btuh', 'بی‌تی‌یو بر ساعت (BTU/h)', 0.29307107),
  ]),
  UnitCategory('چگالی', [
    UnitDef('kgm3', 'کیلوگرم بر مترمکعب (kg/m³)', 1),
    UnitDef('gcm3', 'گرم بر سانتی‌مترمکعب (g/cm³)', 1000),
    UnitDef('tm3', 'تن بر مترمکعب (t/m³)', 1000),
    UnitDef('lbft3', 'پوند بر فوت‌مکعب (lb/ft³)', 16.01846337396),
  ]),
];

double _toCelsius(String key, double v) {
  switch (key) {
    case 'F':
      return (v - 32) * 5 / 9;
    case 'K':
      return v - 273.15;
    default:
      return v;
  }
}

double _fromCelsius(String key, double c) {
  switch (key) {
    case 'F':
      return c * 9 / 5 + 32;
    case 'K':
      return c + 273.15;
    default:
      return c;
  }
}

/// Converts [value] between two units of [category].
double convertUnit(UnitCategory category, String from, String to, double value) {
  if (category.isTemperature) {
    final c = _toCelsius(from, value);
    if (c < -273.15 - 1e-9) {
      throw const FormatException('دما پایین‌تر از صفر مطلق نیست.');
    }
    return _fromCelsius(to, c);
  }
  return value * category.unit(from).factor / category.unit(to).factor;
}

/// Readable number: no float noise, scientific for extremes.
String formatUnitValue(double v) {
  if (v == 0) return '0';
  final a = v.abs();
  if (a >= 1e12 || a < 1e-6) return v.toStringAsExponential(6);
  var s = a >= 1000 ? v.toStringAsFixed(3) : v.toStringAsFixed(8);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return s;
}
