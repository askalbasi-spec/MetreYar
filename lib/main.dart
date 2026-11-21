import 'package:flutter/material.dart';
import 'core/calculations.dart';
import 'quick_estimates.dart';

const _navy = Color(0xFF101B2D);
const _gold = Color(0xFFD6AD55);
const _silver = Color(0xFFD9DEE7);

void main() => runApp(const MetreYarApp());

class MetreYarApp extends StatelessWidget {
  const MetreYarApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _gold,
      brightness: Brightness.dark,
      surface: const Color(0xFF1B2940),
    ).copyWith(
      primary: _gold,
      secondary: const Color(0xFFB9C5D6),
      surface: const Color(0xFF1B2940),
      onSurface: const Color(0xFFF2F4F8),
      outline: const Color(0xFF52627A),
    );
    return MaterialApp(
      title: 'متره‌وبرآوردیار',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: _navy,
        visualDensity: VisualDensity.standard,
        dividerTheme: const DividerThemeData(color: Color(0xFF34445D), thickness: 1),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF1B2940),
          indicatorColor: _gold.withValues(alpha: 0.18),
          labelTextStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w600)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _navy,
          foregroundColor: _silver,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: const TextStyle(color: _silver, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1B2940),
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.22),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF34445D), width: 0.7),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF24344D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: _silver),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('متره‌وبرآوردیار', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('ENGINE PLUS', style: TextStyle(fontSize: 10, letterSpacing: 2, color: _gold)),
          ],
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF344B6C), Color(0xFF1B2940), Color(0xFF142033)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _gold.withValues(alpha: 0.65)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 22, offset: const Offset(0, 10)),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.architecture_rounded, color: _gold, size: 22),
                    SizedBox(width: 8),
                    Text('ENGINE PLUS  |  دفتر فنی هوشمند', style: TextStyle(color: _gold, fontSize: 11, letterSpacing: 0.6, fontWeight: FontWeight.w700)),
                  ]),
                  SizedBox(height: 16),
                  Text('متره و برآورد، دقیق‌تر و سریع‌تر', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, height: 1.5)),
                  SizedBox(height: 8),
                  Text('ابزارهای کاربردی پروژه‌های ساختمانی را در سه گروه تخصصی در اختیار داشته باشید.', style: TextStyle(color: _silver, height: 1.7, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Row(
              children: [
                Text('دسترسی سریع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                SizedBox(width: 8),
                Expanded(child: Divider(color: Color(0xFF52627A))),
              ],
            ),
            const SizedBox(height: 13),
            _ToolCard(
              icon: Icons.foundation_rounded,
              title: 'بتن و سفت‌کاری',
              subtitle: 'بتن‌ریزی، آرماتور و عملیات بنایی',
              onTap: () => _openCalculator(context, const QuickEstimatesPage(initialTabIndex: 0)),
            ),
            _ToolCard(
              icon: Icons.format_paint_rounded,
              title: 'نازک‌کاری',
              subtitle: 'کف‌سازی، اندود، رنگ و پوشش‌ها',
              onTap: () => _openCalculator(context, const QuickEstimatesPage(initialTabIndex: 1)),
            ),
            _ToolCard(
              icon: Icons.electrical_services_rounded,
              title: 'تأسیسات',
              subtitle: 'محاسبات تأسیسات مکانیکی و برقی',
              onTap: () => _openCalculator(context, const QuickEstimatesPage(initialTabIndex: 2)),
            ),
            const SizedBox(height: 14),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: _gold.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(13)),
                  child: const Icon(Icons.grid_view_rounded, color: _gold),
                ),
                title: const Text('فهرست کامل ۵۳ ابزار', style: TextStyle(fontWeight: FontWeight.w800)),
                subtitle: const Text('مشاهده همه محاسبات و راهنماهای مهندسی', style: TextStyle(color: _silver)),
                trailing: const Icon(Icons.chevron_left_rounded, color: _gold),
                onTap: () => _openCalculator(context, const QuickEstimatesPage()),
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text('نسخه 1.2.4  •  اینجین پلاس',
                  style: TextStyle(color: _silver, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  void _openCalculator(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        leading: CircleAvatar(
          radius: 23,
          backgroundColor: _gold.withValues(alpha: 0.14),
          child: Icon(icon, color: _gold),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: _silver)),
        trailing: const Icon(Icons.arrow_back_ios_new_rounded, color: _gold, size: 16),
        onTap: onTap,
      ),
    );
  }
}

abstract class _CalculatorPage extends StatefulWidget {
  const _CalculatorPage({super.key});
}

abstract class _CalculatorPageState<T extends _CalculatorPage> extends State<T> {
  final List<TextEditingController> controllers = [];
  String? result;
  String? error;

  void initializeControllers(int count) {
    controllers.addAll(List.generate(count, (_) => TextEditingController()));
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget numberField(int index, String label, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controllers[index],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, suffixText: unit),
      ),
    );
  }

  double readNumber(int index) {
    final normalized = controllers[index].text
        .replaceAll('۰', '0').replaceAll('۱', '1').replaceAll('۲', '2')
        .replaceAll('۳', '3').replaceAll('۴', '4').replaceAll('۵', '5')
        .replaceAll('۶', '6').replaceAll('۷', '7').replaceAll('۸', '8')
        .replaceAll('۹', '9').replaceAll('٫', '.').replaceAll(',', '.');
    final value = double.tryParse(normalized);
    if (value == null || !value.isFinite || value <= 0) {
      throw const FormatException('لطفاً همه مقادیر را به‌صورت عدد مثبت وارد کنید.');
    }
    return value;
  }

  void calculate(double Function() operation, String unit) {
    setState(() {
      try {
        final value = operation();
        result = '${value.toStringAsFixed(3)} $unit';
        error = null;
      } on Object catch (e) {
        error = e is FormatException ? e.message.toString() : 'مقادیر واردشده معتبر نیستند.';
        result = null;
      }
    });
  }

  Widget buildCalculator({
    required String title,
    required List<Widget> fields,
    required VoidCallback onCalculate,
    required String hint,
  }) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(hint, style: const TextStyle(color: _silver, height: 1.7)),
          const SizedBox(height: 22),
          ...fields,
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onCalculate,
            icon: const Icon(Icons.calculate_outlined),
            label: const Text('محاسبه'),
          ),
          if (result != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const Text('نتیجه محاسبه', style: TextStyle(color: _gold)),
                    const SizedBox(height: 8),
                    Text(result!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: Colors.redAccent)),
          ],
        ],
      ),
    );
  }
}

class ConcreteCalculator extends _CalculatorPage {
  const ConcreteCalculator({super.key});

  @override
  State<ConcreteCalculator> createState() => _ConcreteCalculatorState();
}

class _ConcreteCalculatorState extends _CalculatorPageState<ConcreteCalculator> {
  @override
  void initState() {
    super.initState();
    initializeControllers(3);
  }

  @override
  Widget build(BuildContext context) => buildCalculator(
        title: 'محاسبه حجم بتن',
        hint: 'ابعاد عضو بتنی را بر حسب متر وارد کنید.',
        fields: [
          numberField(0, 'طول', 'متر'),
          numberField(1, 'عرض', 'متر'),
          numberField(2, 'ارتفاع', 'متر'),
        ],
        onCalculate: () => calculate(
          () => MetreYarCalculations.concreteVolume(
            lengthM: readNumber(0), widthM: readNumber(1), heightM: readNumber(2)),
          'متر مکعب',
        ),
      );
}

class RebarCalculator extends _CalculatorPage {
  const RebarCalculator({super.key});

  @override
  State<RebarCalculator> createState() => _RebarCalculatorState();
}

class _RebarCalculatorState extends _CalculatorPageState<RebarCalculator> {
  @override
  void initState() {
    super.initState();
    initializeControllers(2);
  }

  @override
  Widget build(BuildContext context) => buildCalculator(
        title: 'محاسبه وزن میلگرد',
        hint: 'قطر اسمی را بر حسب میلی‌متر و طول کل را بر حسب متر وارد کنید.',
        fields: [numberField(0, 'قطر میلگرد', 'میلی‌متر'), numberField(1, 'طول کل', 'متر')],
        onCalculate: () => calculate(
          () => MetreYarCalculations.rebarWeightKg(
            diameterMm: readNumber(0), totalLengthM: readNumber(1)),
          'کیلوگرم',
        ),
      );
}

class AreaCalculator extends _CalculatorPage {
  const AreaCalculator({super.key});

  @override
  State<AreaCalculator> createState() => _AreaCalculatorState();
}

class _AreaCalculatorState extends _CalculatorPageState<AreaCalculator> {
  @override
  void initState() {
    super.initState();
    initializeControllers(2);
  }

  @override
  Widget build(BuildContext context) => buildCalculator(
        title: 'محاسبه مساحت',
        hint: 'طول و عرض سطح را بر حسب متر وارد کنید.',
        fields: [numberField(0, 'طول', 'متر'), numberField(1, 'عرض', 'متر')],
        onCalculate: () => calculate(
          () => MetreYarCalculations.rectangleArea(
            lengthM: readNumber(0), widthM: readNumber(1)),
          'متر مربع',
        ),
      );
}
