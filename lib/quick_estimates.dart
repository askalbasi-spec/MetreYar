import 'dart:math' as math;

import 'package:flutter/material.dart';

const _gold = Color(0xFFD6AD55);
const _silver = Color(0xFFD9DEE7);

class _InputSpec {
  const _InputSpec(this.key, this.label, this.unit, {this.initial = ''});
  final String key;
  final String label;
  final String unit;
  final String initial;
}

class _EstimateSpec {
  const _EstimateSpec({
    required this.id,
    required this.title,
    required this.description,
    this.formula,
    this.inputs = const [],
    this.resultUnit = '',
    this.warning,
    this.guide,
  });

  final int id;
  final String title;
  final String description;
  final String? formula;
  final List<_InputSpec> inputs;
  final String resultUnit;
  final String? warning;
  final String? guide;
}

const _estimates = <_EstimateSpec>[
  _EstimateSpec(id: 1, title: 'وزن میلگرد در هر متر', description: 'وزن تقریبی میلگرد از روی قطر و طول کل.', formula: 'قطر² ÷ ۱۶۲ × طول', inputs: [_InputSpec('diameter', 'قطر اسمی', 'میلی‌متر'), _InputSpec('length', 'طول کل', 'متر')], resultUnit: 'کیلوگرم', warning: 'وزن واقعی ممکن است با وزن اسمی و تلرانس کارخانه تفاوت داشته باشد.'),
  _EstimateSpec(id: 2, title: 'سرانه میلگرد بر اساس زیربنا', description: 'تخمین مقدار میلگرد با انتخاب بازه مصرف در هر مترمربع.', formula: 'زیربنا × سرانه انتخابی', inputs: [_InputSpec('area', 'زیربنای کل', 'مترمربع'), _InputSpec('rate', 'سرانه مصرف انتخابی', 'کیلوگرم بر مترمربع', initial: '50')], resultUnit: 'کیلوگرم', warning: 'سرانه‌های ۳۵ تا ۷۰ کیلوگرم بر مترمربع صرفاً بازه‌های اولیه‌اند؛ سیستم سازه، دهانه‌ها، تعداد طبقات و نقشه‌ها تعیین‌کننده‌اند.'),
  _EstimateSpec(id: 3, title: 'سرانه میلگرد بر اساس حجم بتن', description: 'برآورد تناژ میلگرد از حجم بتن و نرخ مصرف انتخابی.', formula: 'حجم بتن × سرانه انتخابی', inputs: [_InputSpec('volume', 'حجم بتن', 'مترمکعب'), _InputSpec('rate', 'سرانه مصرف انتخابی', 'کیلوگرم بر مترمکعب', initial: '100')], resultUnit: 'کیلوگرم', warning: 'بازه ۸۰ تا ۱۲۰ و در پروژه‌های پرتراکم تا حدود ۱۵۰ کیلوگرم بر مترمکعب فقط تخمین اولیه است.'),
  _EstimateSpec(id: 4, title: 'سرانه آهن‌آلات اسکلت فولادی', description: 'تخمین وزن فولاد سازه‌ای بدون میلگرد سقف.', formula: 'زیربنا × سرانه انتخابی', inputs: [_InputSpec('area', 'زیربنای کل', 'مترمربع'), _InputSpec('rate', 'سرانه انتخابی', 'کیلوگرم بر مترمربع', initial: '80')], resultUnit: 'کیلوگرم', warning: 'بازه‌های تقریبی اعلام‌شده ۴۵ تا ۱۲۰ کیلوگرم بر مترمربع‌اند و جایگزین طراحی و فهرست مصالح نیستند.'),
  _EstimateSpec(id: 5, title: 'تعداد دهانه مهاربندی', description: 'راهنمای بررسی اولیه آرایش دهانه‌های مهاربندی.', guide: 'تعداد و محل دهانه‌های مهاربندی را نمی‌توان با یک نسبت سرانگشتی عمومی و بدون اطلاعات پلان، سیستم باربر جانبی، نامنظمی، دریفت و ضوابط لرزه‌ای تعیین کرد. این بخش فعلاً چک‌لیست طراحی اولیه است: پلان محورها، طول و عرض ساختمان، محل بازشوها، نوع مهاربند و مسیر انتقال نیرو باید توسط مهندس محاسب بررسی شود.'),
  _EstimateSpec(id: 6, title: 'طول و جانمایی دیوار برشی', description: 'ملاحظات اولیه جانمایی دیوار برشی.', guide: 'طول و ضخامت دیوار برشی تابع ارتفاع و هندسه ساختمان، بارهای جانبی، مقاومت مصالح، حدود شکل‌پذیری، کنترل دریفت و ضوابط لرزه‌ای است. بدون تحلیل سازه عدد ثابت یا فرمول سرانگشتی قابل اتکا وجود ندارد. این راهنما برای یادآوری کنترل تقارن، پیوستگی تا فونداسیون و پرهیز از پیچش نامطلوب است.'),
  _EstimateSpec(id: 7, title: 'تعداد آجر در هر مترمربع دیوار', description: 'تخمین تعداد آجر با سرانه قابل ویرایش.', formula: 'مساحت دیوار × تعداد آجر در مترمربع', inputs: [_InputSpec('area', 'مساحت خالص دیوار', 'مترمربع'), _InputSpec('rate', 'تعداد آجر در هر مترمربع', 'عدد', initial: '70')], resultUnit: 'عدد آجر', warning: 'مقادیر ۷۰، ۱۳۷ و ۲۱۷ عدد به ابعاد آجر، ضخامت واقعی دیوار، بند ملات و پرت وابسته‌اند. بازشوها را از مساحت کم کنید.'),
  _EstimateSpec(id: 8, title: 'ملات دیوارچینی', description: 'برآورد ملات و اجزای سیمان و ماسه با نسبت اختلاط انتخابی.', formula: 'حجم دیوار × ضریب ملات', inputs: [_InputSpec('wall', 'حجم کل دیوار', 'مترمکعب'), _InputSpec('factor', 'سهم حجمی ملات از دیوار', 'ضریب', initial: '0.12'), _InputSpec('cement', 'سیمان در هر مترمکعب ملات', 'کیلوگرم', initial: '300'), _InputSpec('sand', 'ماسه در هر مترمکعب ملات', 'کیلوگرم', initial: '1800')], resultUnit: 'مترمکعب ملات', warning: 'ضریب یک‌سومِ حجم دیوار که گاهی نقل می‌شود برای همه انواع دیوارچینی قابل تعمیم نیست؛ مقدار واقعی به نوع واحد بنایی و ضخامت بندها وابسته است. خروجی سیمان و ماسه نیز تخمینی است.'),
  _EstimateSpec(id: 9, title: 'ملات مصرفی کف‌سازی', description: 'محاسبه ملات بر اساس مساحت و ضخامت لایه.', formula: 'مساحت × ضخامت', inputs: [_InputSpec('area', 'مساحت کف', 'مترمربع'), _InputSpec('thickness', 'ضخامت ملات', 'سانتی‌متر', initial: '3')], resultUnit: 'مترمکعب ملات', warning: 'عدد ۳۰ لیتر بر مترمربع معادل ضخامت متوسط ۳ سانتی‌متر است؛ ضخامت واقعی زیرسازی را اندازه‌گیری کنید.'),
  _EstimateSpec(id: 10, title: 'ملات و اندود سقف', description: 'محاسبه حجم ملات بر اساس سطح و ضخامت واقعی.', formula: 'مساحت × ضخامت', inputs: [_InputSpec('area', 'مساحت سقف', 'مترمربع'), _InputSpec('thickness', 'ضخامت ملات یا اندود', 'سانتی‌متر')], resultUnit: 'مترمکعب', warning: 'اعداد ۵۰۰ و ۷۷۰ لیتر در هر مترمربع که در متن اولیه آمده‌اند بسیار بزرگ و نیازمند راستی‌آزمایی منبع و واحد هستند؛ به‌صورت پیش‌فرض وارد نشده‌اند. ضخامت واقعی را وارد کنید.'),
  _EstimateSpec(id: 11, title: 'انتخاب اولیه نوع فونداسیون', description: 'راهنمای عوامل مؤثر بر انتخاب پی.', guide: 'انتخاب پی منفرد، نواری، گسترده یا عمیق بر اساس نوع خاک به‌تنهایی ممکن نیست. گزارش مکانیک خاک، ظرفیت باربری مجاز، نشست کل و نسبی، سطح آب زیرزمینی، بار ستون‌ها، همجواری‌ها و محدودیت اجرا لازم است. تصمیم نهایی باید بر پایه گزارش ژئوتکنیک و طراحی مهندس محاسب باشد.'),
  _EstimateSpec(id: 12, title: 'ضریب زلزله (C)', description: 'راهنمای پارامترهای ضریب زلزله و استاندارد ۲۸۰۰.', guide: 'ضریب زلزله تابع ویرایش معتبر استاندارد ۲۸۰۰، پهنه خطر نسبی، نوع زمین، اهمیت ساختمان، سیستم سازه‌ای و دوره تناوب است. چون ویرایش و اصلاحیه‌های معتبر باید کنترل شوند، این نسخه عدد ثابت ارائه نمی‌کند. پیش از استفاده، متن رسمی و آخرین اصلاحیه‌های استاندارد ۲۸۰۰ را بررسی کنید.'),
  _EstimateSpec(id: 13, title: 'حجم بتن اجزای مختلف', description: 'محاسبه حجم منشوری یا استوانه‌ای برای اعضای بتنی.', formula: 'منشور: طول × عرض × ارتفاع | استوانه: π × قطر² ÷ ۴ × ارتفاع', inputs: [_InputSpec('length', 'طول یا ارتفاع عضو', 'متر'), _InputSpec('width', 'عرض عضو (برای منشور)', 'متر'), _InputSpec('height', 'ارتفاع / ضخامت', 'متر')], resultUnit: 'مترمکعب', warning: 'برای عضو مستطیلی از هر سه ورودی استفاده می‌شود. برای مخزن یا لوله استوانه‌ای، عرض را برابر قطر داخلی قرار دهید؛ حجم خالص/ناخالص را متناسب با هدف متره انتخاب کنید.'),
  _EstimateSpec(id: 14, title: 'درز انقطاع ساختمان', description: 'راهنمای کنترل فاصله لرزه‌ای ساختمان‌های مجاور.', guide: 'درز انقطاع تابع ارتفاع، جابجایی جانبی طرح، ضوابط استاندارد ۲۸۰۰ و شرایط ساختمان مجاور است. عبارت «تا ۸ طبقه» به‌تنهایی برای تعیین فاصله کافی نیست. مقدار نهایی را از ضابطه معتبر و محاسبات پروژه استخراج کنید و جزئیات پوشش درز را نیز در نظر بگیرید.'),
  _EstimateSpec(id: 15, title: 'سطح اشغال و قاعده ۲۵ متر و ۴۵ درجه', description: 'راهنمای بررسی اولیه نورگیری و محدودیت‌های حجمی.', guide: 'قاعده موسوم به ۲۵ متر و ۴۵ درجه را نباید قانون یکسان و سراسری تلقی کرد. سطح اشغال، عقب‌نشینی، نورگیری و محدودیت ارتفاع تابع طرح تفصیلی، پهنه، دستور نقشه و ضوابط شهرداری محل است. ملاک اجرا، دستور نقشه و مقررات محلیِ به‌روز است.'),
  _EstimateSpec(id: 16, title: 'تأمین پارکینگ و رمپ', description: 'چک‌لیست اولیه پارکینگ فضاهای مختلف.', guide: 'تعداد پارکینگ موردنیاز، ابعاد جای پارک، عرض مسیر، شیب و پاگرد رمپ به کاربری، مساحت، ضوابط شهرداری و مقررات ملی ساختمان وابسته است. بدون شهر و دستور نقشه عدد ثابت قابل اتکا نیست. پیش از تثبیت پلان، گردش خودرو، شعاع گردش، ارتفاع آزاد و دسترسی افراد کم‌توان را نیز بررسی کنید.'),
  _EstimateSpec(id: 17, title: 'ابعاد سرانگشتی پله و آسانسور', description: 'راهنمای کنترل اولیه ابعاد و دسترسی.', guide: 'ابعاد کف و ارتفاع پله، عرض راه‌پله، پاگرد، تعداد پله، ابعاد چاه و کابین آسانسور تابع تعداد و جمعیت استفاده‌کننده، ارتفاع طبقات، کاربری، الزامات آتش‌نشانی و استانداردهای دسترس‌پذیری و آسانسور است. برای نقشه اجرایی به مقررات و استانداردهای جاری مراجعه شود.'),
  _EstimateSpec(id: 18, title: 'عایق‌کاری حرارتی (مبحث ۱۹)', description: 'راهنمای تخمین اولیه عایق پوسته ساختمان.', guide: 'ضخامت عایق موردنیاز با اقلیم، نوع و لایه‌های دیوار، ضریب هدایت حرارتی، پل‌های حرارتی و ویرایش معتبر مبحث ۱۹ تغییر می‌کند. اعداد ۷٫۵ و ۳ سانتی‌متر یا معادل‌سازی مصالح در متن اولیه، بدون تعیین نوع عایق و مشخصات دیوار، نسخه عمومی و قطعی نیستند. محاسبه نهایی باید بر اساس مقاومت حرارتی کل جداره انجام شود.'),
  _EstimateSpec(id: 19, title: 'مقدار رنگ و گچ‌کاری', description: 'برآورد رنگ و ملات گچ بر اساس سطح و نرخ مصرف.', formula: 'مقدار = مساحت × نرخ مصرف', inputs: [_InputSpec('area', 'مساحت سطح', 'مترمربع'), _InputSpec('rate', 'نرخ مصرف برای هر مترمربع', 'کیلوگرم یا لیتر', initial: '1')], resultUnit: 'واحد ماده', warning: 'نرخ مصرف را از مشخصات محصول، تعداد دست اجرا، زیرکار و پرت واقعی بگیرید. برای رنگ و گچ، نرخ مصرف جداگانه تعریف کنید.'),
  _EstimateSpec(id: 20, title: 'آسفالت و کاشی / سرامیک', description: 'محاسبه حجم آسفالت و تعداد قطعات کف‌پوش.', formula: 'آسفالت: مساحت × ضخامت × چگالی | کاشی: مساحت ÷ مساحت هر قطعه', inputs: [_InputSpec('area', 'مساحت اجرا', 'مترمربع'), _InputSpec('thickness', 'ضخامت آسفالت', 'سانتی‌متر', initial: '5'), _InputSpec('density', 'چگالی آسفالت', 'کیلوگرم بر مترمکعب', initial: '2300'), _InputSpec('tileArea', 'مساحت هر کاشی/سرامیک', 'مترمربع', initial: '0.36'), _InputSpec('waste', 'درصد پرت کاشی', 'درصد', initial: '10')], resultUnit: 'کیلوگرم آسفالت و تعداد قطعه', warning: 'برای آسفالت، چگالی را از طرح اختلاط/مشخصات پیمان بگیرید. تعداد کاشی با گرد کردن به بالا و افزودن پرت محاسبه می‌شود.'),
];

class QuickEstimatesPage extends StatelessWidget {
  const QuickEstimatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('۲۰ محاسبه سرانگشتی ساختمان')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _estimates.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _estimates[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _gold.withValues(alpha: .15),
                child: Text('${item.id}', style: const TextStyle(color: _gold, fontWeight: FontWeight.bold)),
              ),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item.description, style: const TextStyle(color: _silver)),
              trailing: const Icon(Icons.chevron_left, color: _gold),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => _EstimateDetailPage(spec: item),
              )),
            ),
          );
        },
      ),
    );
  }
}

class _EstimateDetailPage extends StatefulWidget {
  const _EstimateDetailPage({required this.spec});
  final _EstimateSpec spec;

  @override
  State<_EstimateDetailPage> createState() => _EstimateDetailPageState();
}

class _EstimateDetailPageState extends State<_EstimateDetailPage> {
  final Map<String, TextEditingController> _controllers = {};
  String? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    for (final field in widget.spec.inputs) {
      _controllers[field.key] = TextEditingController(text: field.initial);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _value(String key) {
    final raw = _controllers[key]!.text
        .replaceAll('۰', '0').replaceAll('۱', '1').replaceAll('۲', '2')
        .replaceAll('۳', '3').replaceAll('۴', '4').replaceAll('۵', '5')
        .replaceAll('۶', '6').replaceAll('۷', '7').replaceAll('۸', '8')
        .replaceAll('۹', '9').replaceAll('٫', '.').replaceAll(',', '.');
    final value = double.tryParse(raw);
    if (value == null || !value.isFinite || value <= 0) {
      throw const FormatException('همه مقادیر باید عددی مثبت و معتبر باشند.');
    }
    return value;
  }

  void _calculate() {
    try {
      final v = _value;
      String result;
      switch (widget.spec.id) {
        case 1:
          result = '${(v('diameter') * v('diameter') / 162 * v('length')).toStringAsFixed(2)} کیلوگرم';
        case 2:
        case 4:
        case 7:
        case 19:
          result = (v('area') * v('rate')).toStringAsFixed(2);
          if (widget.spec.id == 2 || widget.spec.id == 4) result += ' کیلوگرم';
          if (widget.spec.id == 7) result += ' عدد آجر';
          if (widget.spec.id == 19) result += ' واحد ماده';
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
          result = '${(v('length') * v('width') * v('height')).toStringAsFixed(3)} مترمکعب';
          result += '\nبرای استوانه: ${(math.pi * math.pow(v('width') / 2, 2) * v('height')).toStringAsFixed(3)} مترمکعب (قطر = عرض)';
        case 20:
          final asphaltKg = v('area') * v('thickness') / 100 * v('density');
          final tiles = (v('area') / v('tileArea') * (1 + v('waste') / 100)).ceil();
          result = 'آسفالت: ${asphaltKg.toStringAsFixed(1)} کیلوگرم\nکاشی/سرامیک با پرت: $tiles عدد';
        default:
          throw const FormatException('برای این مورد محاسبه عددی تعریف نشده است.');
      }
      setState(() { _result = result; _error = null; });
    } on Object catch (e) {
      setState(() { _result = null; _error = e is FormatException ? e.message.toString() : 'ورودی‌ها معتبر نیستند.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    return Scaffold(
      appBar: AppBar(title: Text(spec.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(spec.description, style: const TextStyle(color: _silver, height: 1.7)),
          if (spec.formula != null) ...[
            const SizedBox(height: 12),
            Text('فرمول: ${spec.formula}', style: const TextStyle(color: _gold, height: 1.8)),
          ],
          if (spec.inputs.isNotEmpty) ...[
            const SizedBox(height: 18),
            for (final field in spec.inputs)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _controllers[field.key],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: field.label, suffixText: field.unit),
                ),
              ),
            FilledButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('محاسبه'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 18),
              Card(child: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(_result!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.8)),
              )),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
            ],
          ] else ...[
            const SizedBox(height: 18),
            const Card(child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('راهنمای کنترل اولیه', style: TextStyle(color: _gold, fontWeight: FontWeight.bold)),
            )),
            const SizedBox(height: 8),
            Text(spec.guide ?? '', style: const TextStyle(height: 1.9)),
          ],
          if (spec.warning != null) ...[
            const SizedBox(height: 18),
            Card(
              color: const Color(0xFF332B20),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline, color: _gold),
                  const SizedBox(width: 10),
                  Expanded(child: Text(spec.warning!, style: const TextStyle(height: 1.7))),
                ]),
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Text('این ابزار برای برآورد اولیه و کنترل کارگاهی است و جایگزین نقشه‌ها، مشخصات فنی، گزارش ژئوتکنیک یا محاسبات مهندسی و ضوابط لازم‌الاجرا نیست.', style: TextStyle(color: _silver, fontSize: 12, height: 1.8)),
        ],
      ),
    );
  }
}
