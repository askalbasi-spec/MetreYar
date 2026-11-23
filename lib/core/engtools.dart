import 'dart:math' as math;

/// A labeled input of a form-style tool.
class FieldDef {
  const FieldDef(this.key, this.label, this.unit, {this.initial = '', this.allowZero = false});
  final String key;
  final String label;
  final String unit;
  final String initial;
  final bool allowZero;
}

class ResultRow {
  const ResultRow(this.label, this.value, [this.unit = '']);
  final String label;
  final String value;
  final String unit;
}

String f(double v, [int d = 3]) {
  final s = v.toStringAsFixed(d);
  if (!s.contains('.')) return s;
  return s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

/// A tool made of numeric inputs and a list of results.
class FormTool {
  const FormTool(this.id, this.title, this.description, this.fields, this.compute, {this.note});
  final String id;
  final String title;
  final String description;
  final List<FieldDef> fields;
  final List<ResultRow> Function(Map<String, double> v) compute;
  final String? note;
}

// ---------------------------------------------------------------- geometry

List<ResultRow> rectangle(double a, double b) =>
    [ResultRow('مساحت', f(a * b), 'واحد مربع'), ResultRow('محیط', f(2 * (a + b)), 'واحد طول')];

List<ResultRow> triangle(double a, double b, double c) {
  if (a + b <= c || a + c <= b || b + c <= a) {
    throw const FormatException('سه ضلع مثلث‌ساز نیستند (مجموع هر دو ضلع باید از ضلع سوم بزرگ‌تر باشد).');
  }
  final s = (a + b + c) / 2;
  final area = math.sqrt(s * (s - a) * (s - b) * (s - c));
  return [ResultRow('مساحت', f(area), 'واحد مربع'), ResultRow('محیط', f(a + b + c), 'واحد طول')];
}

List<ResultRow> circle(double d) => [
      ResultRow('مساحت', f(math.pi * d * d / 4), 'واحد مربع'),
      ResultRow('محیط', f(math.pi * d), 'واحد طول'),
    ];

List<ResultRow> trapezoid(double a, double b, double h) =>
    [ResultRow('مساحت', f((a + b) / 2 * h), 'واحد مربع')];

List<ResultRow> box(double l, double w, double h) => [
      ResultRow('حجم', f(l * w * h), 'واحد مکعب'),
      ResultRow('مساحت کل سطوح', f(2 * (l * w + l * h + w * h)), 'واحد مربع'),
    ];

List<ResultRow> cylinder(double d, double h) => [
      ResultRow('حجم', f(math.pi * d * d / 4 * h), 'واحد مکعب'),
      ResultRow('مساحت جانبی', f(math.pi * d * h), 'واحد مربع'),
    ];

List<ResultRow> cone(double d, double h) {
  final r = d / 2;
  return [
    ResultRow('حجم', f(math.pi * r * r * h / 3), 'واحد مکعب'),
    ResultRow('مساحت جانبی', f(math.pi * r * math.sqrt(r * r + h * h)), 'واحد مربع'),
  ];
}

List<ResultRow> sphere(double d) => [
      ResultRow('حجم', f(math.pi * d * d * d / 6), 'واحد مکعب'),
      ResultRow('مساحت سطح', f(math.pi * d * d), 'واحد مربع'),
    ];

// -------------------------------------------------------------------- beam

/// Simply supported beam with a uniform load [w] (kN/m) and a midspan point
/// load [p] (kN) over [l] metres. [e] in GPa, [i] in cm⁴.
List<ResultRow> simpleBeam(double w, double p, double l, double e, double i) {
  if (w <= 0 && p <= 0) {
    throw const FormatException('حداقل یکی از بارها (گسترده یا متمرکز) باید بزرگ‌تر از صفر باشد.');
  }
  final reaction = w * l / 2 + p / 2;
  final mMax = w * l * l / 8 + p * l / 4;
  final lmm = l * 1000;
  final ei = e * 1000 * i * 1e4; // N·mm²
  final defl = 5 * w * math.pow(lmm, 4) / (384 * ei) + p * 1000 * math.pow(lmm, 3) / (48 * ei);
  return [
    ResultRow('عکس‌العمل هر تکیه‌گاه', f(reaction, 2), 'kN'),
    ResultRow('برش بیشینه', f(reaction, 2), 'kN'),
    ResultRow('لنگر خمشی بیشینه (وسط دهانه)', f(mMax, 2), 'kN·m'),
    ResultRow('خیز بیشینه', f(defl, 2), 'mm'),
    ResultRow('نسبت خیز به دهانه', '۱/${(lmm / defl).floor()}', ''),
    ResultRow('کنترل L/250', defl <= lmm / 250 ? 'قابل قبول ✓' : 'نامناسب ✗', ''),
    ResultRow('کنترل L/360 (با نازک‌کاری)', defl <= lmm / 360 ? 'قابل قبول ✓' : 'نامناسب ✗', ''),
  ];
}

// ------------------------------------------------------------------ stairs

List<ResultRow> stairs(double totalHeightCm, double treadCm, double idealRiserCm) {
  var n = (totalHeightCm / idealRiserCm).round();
  if (n < 1) n = 1;
  final riser = totalHeightCm / n;
  final blondel = 2 * riser + treadCm;
  final angle = math.atan(riser / treadCm) * 180 / math.pi;
  return [
    ResultRow('تعداد پله (ارتفاع‌ها)', '$n', 'عدد'),
    ResultRow('ارتفاع هر پله', f(riser, 2), 'cm'),
    ResultRow('طول افقی پلکان', f((n - 1) * treadCm, 1), 'cm'),
    ResultRow('زاویه پلکان', f(angle, 1), 'درجه'),
    ResultRow('رابطه ۲h+b', f(blondel, 1),
        'cm ${blondel >= 60 && blondel <= 64 ? '(راحت ✓)' : '(خارج از ۶۰ تا ۶۴؛ بازبینی کنید)'}'),
  ];
}

// ---------------------------------------------------------------- concrete

/// Approximate mix per batch. [cement] kg/m³, [wc] water/cement ratio,
/// [sandPercent] share of sand in the aggregate, [volume] m³.
List<ResultRow> concreteMix(double cement, double wc, double sandPercent, double volume) {
  if (sandPercent <= 0 || sandPercent >= 100) {
    throw const FormatException('درصد ماسه باید بین ۰ و ۱۰۰ باشد.');
  }
  final water = cement * wc;
  final aggregate = 2400 - cement - water;
  if (aggregate <= 0) throw const FormatException('نسبت‌ها با چگالی بتن ۲۴۰۰ سازگار نیست.');
  final sand = aggregate * sandPercent / 100;
  final gravel = aggregate - sand;
  return [
    ResultRow('سیمان', f(cement * volume, 1), 'kg'),
    ResultRow('کیسه سیمان ۵۰ کیلویی', '${(cement * volume / 50).ceil()}', 'کیسه'),
    ResultRow('آب', f(water * volume, 1), 'لیتر'),
    ResultRow('ماسه', f(sand * volume, 1), 'kg'),
    ResultRow('شن', f(gravel * volume, 1), 'kg'),
  ];
}

// ------------------------------------------------------------------ survey

class DistanceAzimuth {
  const DistanceAzimuth(this.dx, this.dy, this.distance, this.azimuthDeg);
  final double dx, dy, distance, azimuthDeg;
}

/// Distance and azimuth (clockwise from north, 0 to 360) between two points.
/// X is easting, Y is northing.
DistanceAzimuth distanceAzimuth(double x1, double y1, double x2, double y2) {
  final dx = x2 - x1, dy = y2 - y1;
  var az = math.atan2(dx, dy) * 180 / math.pi;
  if (az < 0) az += 360;
  return DistanceAzimuth(dx, dy, math.sqrt(dx * dx + dy * dy), az);
}

String toDms(double deg) {
  var total = (deg * 3600).round();
  final d = total ~/ 3600;
  total %= 3600;
  return "$d° ${total ~/ 60}' ${total % 60}\"";
}

/// Area (shoelace) and perimeter of a polygon given as [x, y] pairs.
({double area, double perimeter}) polygonAreaPerimeter(List<List<double>> pts) {
  if (pts.length < 3) throw const FormatException('حداقل سه نقطه لازم است.');
  var a = 0.0, p = 0.0;
  for (var i = 0; i < pts.length; i++) {
    final j = (i + 1) % pts.length;
    a += pts[i][0] * pts[j][1] - pts[j][0] * pts[i][1];
    p += math.sqrt(math.pow(pts[j][0] - pts[i][0], 2) + math.pow(pts[j][1] - pts[i][1], 2));
  }
  return (area: a.abs() / 2, perimeter: p);
}

// ------------------------------------------------------------- tool lists


FormTool _shape(String id, String title, List<FieldDef> fields, List<ResultRow> Function(Map<String, double>) c) =>
    FormTool(id, title, '', fields, c);

final List<FormTool> shapeTools = [
  _shape('rect', 'مستطیل', const [FieldDef('a', 'طول', 'm'), FieldDef('b', 'عرض', 'm')], (v) => rectangle(v['a']!, v['b']!)),
  _shape('tri', 'مثلث (سه ضلع)', const [FieldDef('a', 'ضلع اول', 'm'), FieldDef('b', 'ضلع دوم', 'm'), FieldDef('c', 'ضلع سوم', 'm')],
      (v) => triangle(v['a']!, v['b']!, v['c']!)),
  _shape('circle', 'دایره', const [FieldDef('d', 'قطر', 'm')], (v) => circle(v['d']!)),
  _shape('trap', 'ذوزنقه', const [FieldDef('a', 'قاعده بزرگ', 'm'), FieldDef('b', 'قاعده کوچک', 'm'), FieldDef('h', 'ارتفاع', 'm')],
      (v) => trapezoid(v['a']!, v['b']!, v['h']!)),
  _shape('box', 'مکعب مستطیل', const [FieldDef('l', 'طول', 'm'), FieldDef('w', 'عرض', 'm'), FieldDef('h', 'ارتفاع', 'm')],
      (v) => box(v['l']!, v['w']!, v['h']!)),
  _shape('cyl', 'استوانه', const [FieldDef('d', 'قطر', 'm'), FieldDef('h', 'ارتفاع', 'm')], (v) => cylinder(v['d']!, v['h']!)),
  _shape('cone', 'مخروط', const [FieldDef('d', 'قطر قاعده', 'm'), FieldDef('h', 'ارتفاع', 'm')], (v) => cone(v['d']!, v['h']!)),
  _shape('sphere', 'کره', const [FieldDef('d', 'قطر', 'm')], (v) => sphere(v['d']!)),
];

final FormTool beamTool = FormTool(
  'beam',
  'تیر ساده (لنگر و خیز)',
  'تیر دو سر مفصل با بار گسترده و بار متمرکز وسط دهانه.',
  const [
    FieldDef('w', 'بار گسترده', 'kN/m', initial: '10', allowZero: true),
    FieldDef('p', 'بار متمرکز وسط دهانه', 'kN', initial: '0', allowZero: true),
    FieldDef('l', 'طول دهانه', 'm', initial: '4'),
    FieldDef('e', 'مدول الاستیسیته (فولاد ۲۰۰، بتن ≈ ۲۵)', 'GPa', initial: '200'),
    FieldDef('i', 'ممان اینرسی مقطع', 'cm⁴', initial: '10000'),
  ],
  (v) => simpleBeam(v['w']!, v['p']!, v['l']!, v['e']!, v['i']!),
  note: 'نتیجه برای بارهای بهره‌برداری (بدون ضریب) و محاسبه‌ی اولیه است؛ طراحی نهایی با مهندس سازه.',
);

final FormTool stairTool = FormTool(
  'stairs',
  'پلکان',
  'تعداد و ارتفاع پله‌ها از ارتفاع طبقه.',
  const [
    FieldDef('h', 'ارتفاع کف تا کف', 'cm', initial: '300'),
    FieldDef('b', 'عرض کف‌پله (کف‌خور)', 'cm', initial: '28'),
    FieldDef('r', 'ارتفاع مطلوب هر پله', 'cm', initial: '17'),
  ],
  (v) => stairs(v['h']!, v['b']!, v['r']!),
);

final FormTool mixTool = FormTool(
  'mix',
  'مصالح بتن (طرح اختلاط تقریبی)',
  'مقدار سیمان، آب، ماسه و شن برای حجم دلخواه.',
  const [
    FieldDef('c', 'عیار سیمان', 'kg/m³', initial: '350'),
    FieldDef('wc', 'نسبت آب به سیمان', '', initial: '0.45'),
    FieldDef('s', 'سهم ماسه از سنگدانه', '٪', initial: '45'),
    FieldDef('v', 'حجم بتن', 'm³', initial: '1'),
  ],
  (v) => concreteMix(v['c']!, v['wc']!, v['s']!, v['v']!),
  note: 'تخمین اولیه با چگالی بتن ۲۴۰۰ kg/m³ و سنگدانه‌ی خشک است؛ طرح اختلاط نهایی را آزمایشگاه تعیین می‌کند.',
);
