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
    );
    return MaterialApp(
      title: 'متره‌وبرآوردیار',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: _navy,
        appBarTheme: const AppBarTheme(
          backgroundColor: _navy,
          foregroundColor: _silver,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(color: Color(0xFF1B2940)),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF263A58), Color(0xFF17243A)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _gold.withValues(alpha: 0.55)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ابزار هوشمند دفتر فنی', style: TextStyle(color: _gold, fontSize: 13)),
                  SizedBox(height: 10),
                  Text(
                    'متره، محاسبه و برآورد پروژه‌های ساختمانی',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.6),
                  ),
                  SizedBox(height: 8),
                  Text('محاسبات پایه به‌صورت آفلاین در دسترس شماست.',
                      style: TextStyle(color: _silver, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('دسترسی سریع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _ToolCard(
              icon: Icons.view_in_ar_outlined,
              title: 'حجم بتن',
              subtitle: 'محاسبه حجم فونداسیون، ستون و تیر',
              onTap: () => _openCalculator(context, quickEstimatePage(51)),
            ),
            _ToolCard(
              icon: Icons.straighten,
              title: 'وزن میلگرد',
              subtitle: 'برآورد وزن بر اساس قطر و طول',
              onTap: () => _openCalculator(context, quickEstimatePage(52)),
            ),
            _ToolCard(
              icon: Icons.square_foot,
              title: 'مساحت',
              subtitle: 'محاسبه مساحت سطوح مستطیلی',
              onTap: () => _openCalculator(context, quickEstimatePage(53)),
            ),
            _ToolCard(
              icon: Icons.construction_outlined,
              title: 'همه ابزارهای متره و برآورد',
              subtitle: 'دسته‌بندی‌شده در سه تب اصلی',
              onTap: () => _openCalculator(context, const QuickEstimatesPage()),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text('نسخه 1.2.2  •  اینجین پلاس',
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        leading: CircleAvatar(
          backgroundColor: _gold.withValues(alpha: 0.14),
          child: Icon(icon, color: _gold),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: _silver)),
        trailing: const Icon(Icons.chevron_left, color: _gold),
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
