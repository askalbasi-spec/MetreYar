import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/economy.dart';
import '../core/format.dart';
import '../core/leveling.dart';
import '../core/numbers.dart';
import '../shop_page.dart';

class _RowCtl {
  final label = TextEditingController();
  final bs = TextEditingController();
  final isr = TextEditingController();
  final fs = TextEditingController();
  void dispose() {
    label.dispose();
    bs.dispose();
    isr.dispose();
    fs.dispose();
  }
}

/// Leveling book (height-of-instrument method) with arithmetic check and
/// misclosure control.
class LevelingPage extends StatefulWidget {
  const LevelingPage({super.key});

  @override
  State<LevelingPage> createState() => _LevelingPageState();
}

class _LevelingPageState extends State<LevelingPage> {
  final _start = TextEditingController(text: '100');
  final _end = TextEditingController();
  final _km = TextEditingController();
  final List<_RowCtl> _rows = [_RowCtl(), _RowCtl()];
  LevelResult? _result;
  String? _error;
  String? _verdict;

  @override
  void dispose() {
    _start.dispose();
    _end.dispose();
    _km.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c, String label, {bool required = false}) {
    final t = c.text.trim();
    if (t.isEmpty) {
      if (required) throw FormatException('مقدار «$label» را وارد کنید.');
      return null;
    }
    // Levels may be zero or negative, so parse by hand around the helper.
    final negative = t.startsWith('-') || t.startsWith('−');
    final body = negative ? t.substring(1) : t;
    final v = parseEstimateNumber(body, label: label, allowZero: true);
    return negative ? -v : v;
  }

  List<LevelRow> _collect() {
    final out = <LevelRow>[];
    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      final n = 'ردیف ${fa(i + 1)}';
      final bs = _num(r.bs, 'BS $n');
      final isr = _num(r.isr, 'IS $n');
      final fs = _num(r.fs, 'FS $n');
      if (i == 0 && bs == null) {
        throw const FormatException('ردیف اول باید قرائت BS (دید عقب روی نقطه معلوم) داشته باشد.');
      }
      if (bs == null && isr == null && fs == null) {
        throw FormatException('در $n حداقل یک قرائت وارد کنید.');
      }
      out.add(LevelRow(label: r.label.text.trim(), bs: bs, isr: isr, fs: fs));
    }
    return out;
  }

  void _calculate() {
    try {
      final startRl = _num(_start, 'تراز نقطه شروع', required: true)!;
      final rows = _collect();
      final res = reduceLevels(rows, startRl);
      String? verdict;
      final endKnown = _num(_end, 'تراز معلوم نقطه پایان');
      final km = _num(_km, 'طول مسیر (کیلومتر)');
      if (endKnown != null && res.lastRl != null) {
        final mis = misclosureMm(res.lastRl!, endKnown);
        verdict = 'خطای بست: ${fa(mis.toStringAsFixed(1))} میلی‌متر';
        if (km != null && km > 0) {
          final allow = allowableMisclosureMm(km);
          verdict += ' | مجاز (۱۰√K): ${fa(allow.toStringAsFixed(1))} میلی‌متر → ${mis.abs() <= allow ? 'قابل قبول ✓' : 'غیرمجاز، تکرار نقشه‌برداری لازم است ✗'}';
        } else {
          verdict += ' (برای مقایسه با حد مجاز، طول مسیر را به کیلومتر وارد کنید)';
        }
      }
      setState(() {
        _result = res;
        _verdict = verdict;
        _error = null;
      });
    } on FormatException catch (e) {
      setState(() {
        _error = e.message;
        _result = null;
        _verdict = null;
      });
    }
  }

  String _book() {
    final res = _result!;
    final b = StringBuffer('نقطه\tBS\tIS\tFS\tتراز\n');
    for (var i = 0; i < _rows.length; i++) {
      final r = _rows[i];
      final rl = res.rl[i];
      b.writeln('${r.label.text}\t${r.bs.text}\t${r.isr.text}\t${r.fs.text}\t${rl == null ? '' : rl.toStringAsFixed(3)}');
    }
    b.writeln('جمع\t${res.sumBs.toStringAsFixed(3)}\t\t${res.sumFs.toStringAsFixed(3)}\t');
    if (_verdict != null) b.writeln(_verdict);
    return b.toString();
  }

  Future<void> _export() async {
    if (_result == null) return;
    final ok = await payWithCoins(context, Cost.levelingExport, 'خروجی دفتر ترازیابی',
        openShop: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ShopPage())));
    if (!ok || !mounted) return;
    await Clipboard.setData(ClipboardData(text: _book()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('دفتر ترازیابی کپی شد؛ در اکسل Paste کنید.')));
  }

  Widget _field(TextEditingController c, String l, {bool text = false}) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: TextField(
            controller: c,
            keyboardType: text ? TextInputType.text : const TextInputType.numberWithOptions(decimal: true, signed: true),
            decoration: InputDecoration(labelText: l, isDense: true),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final res = _result;
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('دفتر ترازیابی (نیوو)')),
        body: ListView(
          padding: const EdgeInsets.all(14),
          children: [
            Text(
              'روش ارتفاع دوربین: ردیف اول روی نقطه معلوم فقط BS دارد. هر نقطه تغییر مکان دوربین هم FS دارد و هم BS؛ نقطه‌های میانی فقط IS؛ ردیف آخر فقط FS. قرائت‌ها را به متر وارد کنید.',
              style: TextStyle(fontSize: 12, color: scheme.secondary, height: 1.7),
            ),
            const SizedBox(height: 10),
            Row(children: [
              _field(_start, 'تراز نقطه شروع (متر)'),
              _field(_end, 'تراز معلوم پایان (اختیاری)'),
              _field(_km, 'طول مسیر km'),
            ]),
            const SizedBox(height: 12),
            for (var i = 0; i < _rows.length; i++)
              Card(
                key: ObjectKey(_rows[i]),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(children: [
                    Row(children: [
                      CircleAvatar(radius: 13, child: Text(fa(i + 1), style: const TextStyle(fontSize: 12))),
                      _field(_rows[i].label, 'نام نقطه', text: true),
                      if (_rows.length > 2)
                        IconButton(
                          tooltip: 'حذف ردیف',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => setState(() {
                            _rows.removeAt(i).dispose();
                            _result = null;
                          }),
                        ),
                    ]),
                    const SizedBox(height: 6),
                    Row(children: [
                      _field(_rows[i].bs, 'BS'),
                      _field(_rows[i].isr, 'IS'),
                      _field(_rows[i].fs, 'FS'),
                    ]),
                    if (res != null && res.rl[i] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('تراز: ${fa(res.rl[i]!.toStringAsFixed(3))} متر',
                            style: TextStyle(fontWeight: FontWeight.w800, color: scheme.primary)),
                      ),
                  ]),
                ),
              ),
            Row(children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _rows.add(_RowCtl())),
                icon: const Icon(Icons.add),
                label: const Text('افزودن ردیف'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  key: const Key('level-calc'),
                  onPressed: _calculate,
                  icon: const Icon(Icons.calculate_outlined),
                  label: const Text('محاسبه ترازها'),
                ),
              ),
            ]),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error!, key: const Key('level-error'), style: TextStyle(color: scheme.error)),
              ),
            if (res != null) ...[
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('ΣBS = ${fa(res.sumBs.toStringAsFixed(3))}   ΣFS = ${fa(res.sumFs.toStringAsFixed(3))}'),
                    Text('ΣBS − ΣFS = ${fa((res.sumBs - res.sumFs).toStringAsFixed(3))}'),
                    const SizedBox(height: 4),
                    Text(
                      res.arithmeticOk ? 'کنترل حسابی درست است ✓' : 'کنترل حسابی نادرست است؛ جمع‌ها و قرائت‌ها را بازبینی کنید ✗',
                      key: const Key('arith'),
                      style: TextStyle(fontWeight: FontWeight.w800, color: res.arithmeticOk ? Colors.green : scheme.error),
                    ),
                    if (_verdict != null) ...[
                      const SizedBox(height: 6),
                      Text(_verdict!, key: const Key('misclosure'), style: const TextStyle(height: 1.7)),
                    ],
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _export,
                icon: const Icon(Icons.copy_all),
                label: Text(context.economy.isPro ? 'کپی دفتر برای اکسل' : 'کپی دفتر برای اکسل (${fa(Cost.levelingExport)} سکه)'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
