import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/calculations.dart';
import 'quick_estimates.dart';
import 'workspace.dart';

const _gold = Color(0xFFD6AD55);
const _silver = Color(0xFFD9DEE7);

class AppPalette {
  const AppPalette(this.name, this.subtitle, this.background, this.surface, this.primary, this.secondary, this.accent, this.onSurface);
  final String name, subtitle;
  final Color background, surface, primary, secondary, accent, onSurface;
}

const _palettes = <String, AppPalette>{
  'midnight': AppPalette('سرمه‌ای و طلایی', 'تم اصلی اینجین پلاس', Color(0xFF101B2D), Color(0xFF1B2940), Color(0xFFD6AD55), Color(0xFFB9C5D6), Color(0xFF52627A), Color(0xFFF2F4F8)),
  'concrete': AppPalette('خاکستری صنعتی / بتنی', 'Industrial Concrete', Color(0xFF2F3640), Color(0xFF46505C), Color(0xFFE67E22), Color(0xFFDCDDE1), Color(0xFF7F8C8D), Color(0xFFFFFFFF)),
  'blueprint': AppPalette('آبی مهندسی / نقشه فنی', 'Engineering Blueprint', Color(0xFF1B3A5C), Color(0xFF244D73), Color(0xFFF1C40F), Color(0xFFD6EAF8), Color(0xFF3498DB), Color(0xFFFFFFFF)),
  'green': AppPalette('سبز ایمنی / پایداری', 'Safety Green', Color(0xFF1E5631), Color(0xFF2B7042), Color(0xFFC0392B), Color(0xFFD5F5E3), Color(0xFF4C9A2A), Color(0xFFFFFFFF)),
  'fire': AppPalette('قرمز-خاکستری هشدار', 'Fire Hazard', Color(0xFF922B21), Color(0xFF34495E), Color(0xFFF39C12), Color(0xFFEAECEE), Color(0xFFE74C3C), Color(0xFFFFFFFF)),
};

void main() => runApp(const MetreYarApp());

class MetreYarApp extends StatefulWidget {
  const MetreYarApp({super.key});
  @override
  State<MetreYarApp> createState() => _MetreYarAppState();
}

class _MetreYarAppState extends State<MetreYarApp> {
  String _themeKey = 'midnight';
  Map<String, String> _profile = {'firstName': '', 'lastName': '', 'phone': '', 'field': '', 'jobTitle': '', 'city': '', 'avatar': 'engineering'};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _themeKey = _palettes.containsKey(prefs.getString('themeKey')) ? prefs.getString('themeKey')! : 'midnight';
      for (final key in _profile.keys.toList()) {
        _profile[key] = prefs.getString('profile.$key') ?? '';
      }
      if (_profile['avatar']!.isEmpty) _profile['avatar'] = 'engineering';
      _loaded = true;
    });
  }

  Future<void> _saveTheme(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeKey', key);
    if (mounted) setState(() => _themeKey = key);
  }

  Future<void> _saveProfile(Map<String, String> value) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in value.entries) {
      await prefs.setString('profile.${entry.key}', entry.value);
    }
    if (mounted) setState(() => _profile = Map<String, String>.from(value));
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palettes[_themeKey]!;
    final scheme = ColorScheme.fromSeed(seedColor: palette.primary, brightness: Brightness.dark, surface: palette.surface).copyWith(
      primary: palette.primary, secondary: palette.secondary, surface: palette.surface,
      onSurface: palette.onSurface, outline: palette.accent,
    );
    return MaterialApp(
      title: 'متره‌وبرآوردیار', debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, colorScheme: scheme, scaffoldBackgroundColor: palette.background,
        visualDensity: VisualDensity.standard,
        dividerTheme: DividerThemeData(color: palette.accent.withValues(alpha: .7), thickness: 1),
        appBarTheme: AppBarTheme(backgroundColor: palette.background, foregroundColor: palette.onSurface, centerTitle: true, elevation: 0,
          titleTextStyle: TextStyle(color: palette.onSurface, fontSize: 18, fontWeight: FontWeight.w800)),
        cardTheme: CardThemeData(color: palette.surface, elevation: 3, shadowColor: Colors.black.withValues(alpha: .25), margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: palette.accent.withValues(alpha: .75), width: .7))),
        inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: palette.surface.withValues(alpha: .9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          labelStyle: TextStyle(color: palette.secondary)),
        navigationBarTheme: NavigationBarThemeData(backgroundColor: palette.surface, indicatorColor: palette.primary.withValues(alpha: .18)),
      ),
      home: Directionality(textDirection: TextDirection.rtl, child: _loaded
        ? HomePage(profile: _profile, palette: palette,
            onOpenProfile: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProfilePage(initialProfile: _profile, onSaved: _saveProfile))),
            onOpenSettings: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SettingsPage(
              selectedTheme: _themeKey, profile: _profile, onThemeChanged: _saveTheme, onProfileSaved: _saveProfile))))
        : const Scaffold(body: Center(child: CircularProgressIndicator()))),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.profile, required this.palette, required this.onOpenSettings, required this.onOpenProfile});
  final Map<String, String> profile;
  final AppPalette palette;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final fullName = '${profile['firstName'] ?? ''} ${profile['lastName'] ?? ''}'.trim();
    final avatar = _avatarFor(profile['avatar'] ?? 'engineering');
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: const Column(mainAxisSize: MainAxisSize.min, children: [
          Text('متره و برآوردیار', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
          SizedBox(height: 3),
          Text('ENGINE PLUS  |  دفتر فنی هوشمند', style: TextStyle(fontSize: 11, letterSpacing: .5, color: _gold)),
        ]),
        actions: [IconButton(tooltip: 'تنظیمات', onPressed: onOpenSettings, icon: const Icon(Icons.settings_outlined))],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onOpenProfile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.accent.withValues(alpha: .8)),
                ),
                child: Row(children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: palette.primary.withValues(alpha: .2),
                    child: Text(avatar, style: const TextStyle(fontSize: 23)),
                  ),
                  const SizedBox(width: 11),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(fullName.isEmpty ? 'مهندس گرامی، خوش آمدید' : fullName,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                    Text(fullName.isEmpty ? 'برای ثبت مشخصات، اینجا را لمس کنید' : (profile['field']?.isNotEmpty == true ? profile['field']! : 'پروفایل کاربری'),
                      style: TextStyle(color: palette.secondary, fontSize: 11)),
                  ])),
                  Icon(Icons.edit_outlined, color: palette.primary, size: 19),
                ]),
              ),
            ),
            const SizedBox(height: 13),
            _metalPanel(
              palette: palette,
              child: Column(children: [
                Text('متره و برآورد، دقیق‌تر و سریع‌تر',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.primary, fontSize: 19, fontWeight: FontWeight.w900, height: 1.5)),
                const SizedBox(height: 7),
                Text('ابزارهای کاربردی پروژه‌های ساختمانی',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.onSurface, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('محاسبات کارگاهی',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.secondary, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 17),
            _sectionPanel(
              palette: palette,
              title: 'دسترسی سریع',
              child: Column(children: [
                Row(children: [
                  Expanded(child: _quickAccessButton(
                    palette: palette, icon: Icons.format_paint_outlined, title: 'نازک‌کاری',
                    onTap: () => _openCalculator(context, const QuickEstimatesPage(initialTabIndex: 1)))),
                  const SizedBox(width: 9),
                  Expanded(child: _quickAccessButton(
                    palette: palette, icon: Icons.foundation_outlined, title: 'بتن و سفت‌کاری',
                    onTap: () => _openCalculator(context, const QuickEstimatesPage(initialTabIndex: 0)))),
                ]),
                const SizedBox(height: 9),
                SizedBox(width: double.infinity, child: _quickAccessButton(
                  palette: palette, icon: Icons.plumbing_outlined, title: 'تأسیسات ( مکانیکی – برقی )',
                  onTap: () => _openCalculator(context, const QuickEstimatesPage(initialTabIndex: 2)))),
              ]),
            ),
            const SizedBox(height: 15),
            _sectionPanel(
              palette: palette,
              title: 'آخرین محاسبات',
              child: _RecentCalculations(
                palette: palette,
                onOpenHistory: () => _openCalculator(context, const WorkspacePage(initialTab: 1)),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB477),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(color: const Color(0xFFFFD18D), width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .2), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('نکته اجرایی امروز', style: TextStyle(color: Color(0xFF172033), fontSize: 17, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('رعایت پوشش بتن (کاور) در فونداسیون برای جلوگیری از زنگ‌زدگی میلگردها الزامی است.',
                  style: TextStyle(color: Color(0xFF172033), height: 1.7, fontSize: 13, fontWeight: FontWeight.w700)),
                SizedBox(height: 5),
                Text('نکته: قبل از بتن‌ریزی، مربوط کردن قالب‌ها فراموش نشود.',
                  style: TextStyle(color: Color(0xFF172033), height: 1.7, fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
            ),
            const SizedBox(height: 13),
            OutlinedButton.icon(
              onPressed: () => _openCalculator(context, const WorkspacePage()),
              icon: const Icon(Icons.workspaces_outline),
              label: const Text('پروژه‌ها، سوابق، تبدیل واحد و برآورد هزینه'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _openCalculator(context, const QuickEstimatesPage()),
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('فهرست کامل ۵۳ ابزار'),
            ),
            const SizedBox(height: 8),
            Center(child: Text('ENGINE PLUS', style: TextStyle(color: palette.secondary, fontSize: 10, letterSpacing: 2))),
          ],
        ),
      ),
    );
  }

  Widget _metalPanel({required AppPalette palette, required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [palette.surface, palette.background, palette.surface], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(21),
      border: Border.all(color: palette.primary.withValues(alpha: .9), width: 1.6),
      boxShadow: [BoxShadow(color: palette.primary.withValues(alpha: .14), blurRadius: 17, spreadRadius: 1)],
    ),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.secondary.withValues(alpha: .55)),
      ),
      child: child,
    ),
  );

  Widget _sectionPanel({required AppPalette palette, required String title, required Widget child}) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: palette.surface,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: palette.accent.withValues(alpha: .9), width: 1),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .18), blurRadius: 9, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(padding: const EdgeInsets.only(bottom: 10, right: 3),
        child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
      child,
    ]),
  );

  Widget _quickAccessButton({required AppPalette palette, required IconData icon, required String title, required VoidCallback onTap}) =>
    Material(
      color: palette.background.withValues(alpha: .65),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(13), border: Border.all(color: palette.secondary.withValues(alpha: .65))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Flexible(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
            const SizedBox(width: 7),
            Icon(icon, color: palette.primary, size: 23),
          ]),
        ),
      ),
    );

  Widget _recentCalculation(AppPalette palette, String title, String tag, IconData icon, VoidCallback onTap) =>
    Material(
      color: palette.background.withValues(alpha: .82),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: palette.accent.withValues(alpha: .7))),
          child: Row(children: [
            Icon(icon, color: palette.primary, size: 22),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
            Text(tag, style: TextStyle(color: palette.primary, fontSize: 11, fontWeight: FontWeight.w800)),
          ]),
        ),
      ),
    );

  void _openCalculator(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
}

class _RecentCalculations extends StatefulWidget {
  const _RecentCalculations({required this.palette, required this.onOpenHistory});
  final AppPalette palette;
  final VoidCallback onOpenHistory;
  @override State<_RecentCalculations> createState() => _RecentCalculationsState();
}

class _RecentCalculationsState extends State<_RecentCalculations> {
  late Future<List<Map<String, dynamic>>> _history;
  @override void initState() { super.initState(); _reload(); }
  void _reload() { _history = WorkspaceStore.history(); }
  @override Widget build(BuildContext context) => FutureBuilder<List<Map<String, dynamic>>>(
    future: _history,
    builder: (context, snapshot) {
      final items = snapshot.data ?? const <Map<String, dynamic>>[];
      if (snapshot.connectionState != ConnectionState.done) return const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()));
      if (items.isEmpty) return Text('هنوز محاسبه‌ای ثبت نشده است. پس از انجام محاسبه، سه مورد آخر اینجا نمایش داده می‌شود.', style: TextStyle(color: widget.palette.secondary, height: 1.7));
      return Column(children: [
        for (var i = 0; i < items.take(3).length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Material(color: widget.palette.background.withValues(alpha: .82), borderRadius: BorderRadius.circular(12), child: InkWell(
            onTap: widget.onOpenHistory, borderRadius: BorderRadius.circular(12),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: widget.palette.accent.withValues(alpha: .7))),
              child: Row(children: [
                Icon(Icons.calculate_outlined, color: widget.palette.primary, size: 22), const SizedBox(width: 8),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(items[i]['title']?.toString() ?? 'محاسبه', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 3), Text(items[i]['result']?.toString() ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: widget.palette.secondary, fontSize: 10)),
                ])),
                if ((items[i]['projectName']?.toString() ?? '').isNotEmpty) Text(items[i]['projectName'].toString(), style: TextStyle(color: widget.palette.primary, fontSize: 10)),
              ])),
          )),
        ],
        Align(alignment: Alignment.centerLeft, child: TextButton.icon(onPressed: widget.onOpenHistory, icon: const Icon(Icons.history), label: const Text('مشاهده همه سوابق'))),
      ]);
    },
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.selectedTheme, required this.profile, required this.onThemeChanged, required this.onProfileSaved});
  final String selectedTheme;
  final Map<String, String> profile;
  final ValueChanged<String> onThemeChanged;
  final Future<void> Function(Map<String, String>) onProfileSaved;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('تنظیمات برنامه')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('انتخاب پوسته ظاهری', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        const Text('با انتخاب هر تم، رنگ‌بندی بخش‌های اصلی برنامه تغییر می‌کند.'),
        const SizedBox(height: 12),
        for (final entry in _palettes.entries)
          Card(child: ListTile(
            leading: Container(width: 48, height: 42, decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), gradient: LinearGradient(colors: [entry.value.background, entry.value.surface, entry.value.primary])),
              child: const Icon(Icons.palette_outlined, color: Colors.white)),
            title: Text(entry.value.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(entry.value.subtitle),
            trailing: selectedTheme == entry.key ? Icon(Icons.check_circle, color: entry.value.primary) : const Icon(Icons.chevron_left),
            onTap: () => onThemeChanged(entry.key),
          )),
        const SizedBox(height: 20),
        Card(child: ListTile(leading: const Icon(Icons.person_outline), title: const Text('مشخصات کاربری', style: TextStyle(fontWeight: FontWeight.w800)),
          subtitle: const Text('نام، تماس، رشته و آواتار'), trailing: const Icon(Icons.chevron_left),
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ProfilePage(initialProfile: profile, onSaved: onProfileSaved))))),
      ]));
  }
}

const _avatars = <String, String>{'engineering': '👷', 'architect': '📐', 'builder': '🏗️', 'helmet': '⛑️', 'person': '👤', 'woman': '👩‍💼', 'man': '👨‍💼'};

String _avatarFor(String key) => _avatars[key] ?? '👤';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.initialProfile, required this.onSaved});
  final Map<String, String> initialProfile;
  final Future<void> Function(Map<String, String>) onSaved;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final Map<String, TextEditingController> _fields;
  late String _avatar;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _fields = {for (final key in ['firstName','lastName','phone','field','jobTitle','city']) key: TextEditingController(text: widget.initialProfile[key] ?? '')};
    _avatar = widget.initialProfile['avatar'] ?? 'engineering';
  }

  @override
  void dispose() { for (final c in _fields.values) { c.dispose(); } super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('پروفایل کاربر')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        Center(child: Column(children: [
          CircleAvatar(radius: 38, child: Text(_avatarFor(_avatar), style: const TextStyle(fontSize: 36))),
          const SizedBox(height: 8), const Text('انتخاب آواتار', style: TextStyle(fontWeight: FontWeight.w800)),
        ])),
        const SizedBox(height: 8),
        Wrap(alignment: WrapAlignment.center, spacing: 8, children: _avatars.entries.map((entry) => ChoiceChip(
          label: Text(entry.value, style: const TextStyle(fontSize: 22)), selected: _avatar == entry.key,
          onSelected: (_) => setState(() => _avatar = entry.key))).toList()),
        const SizedBox(height: 18),
        _field('firstName', 'نام', 'نام خود را وارد کنید'),
        _field('lastName', 'نام خانوادگی', 'نام خانوادگی خود را وارد کنید'),
        _field('phone', 'شماره تماس', 'مثلاً 09xxxxxxxxx', keyboard: TextInputType.phone),
        _field('field', 'رشته تحصیلی / تخصص', 'مثلاً مهندسی عمران'),
        _field('jobTitle', 'عنوان شغلی', 'مثلاً مهندس ناظر، مجری، مترور'),
        _field('city', 'شهر محل فعالیت', 'نام شهر'),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save_outlined),
          label: Text(_saving ? 'در حال ذخیره...' : 'ذخیره مشخصات')),
      ]));
  }

  Widget _field(String key, String label, String hint, {TextInputType keyboard = TextInputType.text}) =>
    Padding(padding: const EdgeInsets.only(bottom: 12), child: TextField(controller: _fields[key], keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, hintText: hint)));

  Future<void> _save() async {
    setState(() => _saving = true);
    final data = {for (final entry in _fields.entries) entry.key: entry.value.text.trim(), 'avatar': _avatar};
    await widget.onSaved(data);
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('مشخصات کاربری ذخیره شد.')));
    Navigator.of(context).pop();
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
