import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/expr.dart';
import '../core/format.dart';

/// Scientific calculator with a typed expression line and a keypad.
class ScientificPage extends StatefulWidget {
  const ScientificPage({super.key});

  @override
  State<ScientificPage> createState() => _ScientificPageState();
}

class _ScientificPageState extends State<ScientificPage> {
  final _controller = TextEditingController();
  bool _degrees = true;
  double _ans = 0;
  String? _result;
  String? _error;
  final List<String> _history = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insert(String text) {
    final sel = _controller.selection;
    final value = _controller.text;
    final start = sel.isValid ? sel.start : value.length;
    final end = sel.isValid ? sel.end : value.length;
    final next = value.replaceRange(start, end, text);
    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + text.length),
    );
    setState(() {});
  }

  void _backspace() {
    final value = _controller.text;
    if (value.isEmpty) return;
    final sel = _controller.selection;
    final pos = sel.isValid && sel.isCollapsed ? sel.start : value.length;
    if (pos == 0) return;
    _controller.value = TextEditingValue(
      text: value.replaceRange(pos - 1, pos, ''),
      selection: TextSelection.collapsed(offset: pos - 1),
    );
    setState(() {});
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _result = null;
      _error = null;
    });
  }

  void _equals() {
    try {
      final v = ExprEvaluator(degrees: _degrees, ans: _ans).evaluate(_controller.text);
      final text = formatResult(v);
      setState(() {
        _ans = v;
        _result = text;
        _error = null;
        _history.insert(0, '${_controller.text} = $text');
        if (_history.length > 20) _history.removeLast();
      });
    } on ExprException catch (e) {
      setState(() {
        _error = e.message;
        _result = null;
      });
    }
  }

  Widget _key(String label, {String? insert, VoidCallback? onTap, bool strong = false}) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(3),
      child: SizedBox(
        height: 46,
        child: strong
            ? FilledButton(onPressed: onTap ?? () => _insert(insert ?? label), child: Text(label, style: const TextStyle(fontSize: 16)))
            : OutlinedButton(
                onPressed: onTap ?? () => _insert(insert ?? label),
                style: OutlinedButton.styleFrom(foregroundColor: scheme.onSurface, padding: EdgeInsets.zero),
                child: Text(label, style: const TextStyle(fontSize: 14)),
              ),
      ),
    );
  }

  Widget _row(List<Widget> keys) => Row(children: [for (final k in keys) Expanded(child: k)]);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ماشین‌حساب مهندسی'),
          actions: [
            TextButton(
              key: const Key('deg-toggle'),
              onPressed: () => setState(() => _degrees = !_degrees),
              child: Text(_degrees ? 'درجه (DEG)' : 'رادیان (RAD)'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                key: const Key('expr-field'),
                controller: _controller,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 22),
                keyboardType: TextInputType.none,
                inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\n'))],
                onSubmitted: (_) => _equals(),
                decoration: const InputDecoration(hintText: 'مثلاً sin(30)+2×(3+4)'),
              ),
            ),
            const SizedBox(height: 8),
            if (_result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: SelectableText(
                          key: const Key('result'),
                          _result!,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'کپی',
                      icon: const Icon(Icons.copy),
                      onPressed: () => Clipboard.setData(ClipboardData(text: _result!)),
                    ),
                  ]),
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(_error!, key: const Key('error'), style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ),
            const SizedBox(height: 6),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Column(children: [
                _row([_key('sin', insert: 'sin('), _key('cos', insert: 'cos('), _key('tan', insert: 'tan('), _key('√', insert: 'sqrt('), _key('x²', insert: '^2')]),
                _row([_key('asin', insert: 'asin('), _key('acos', insert: 'acos('), _key('atan', insert: 'atan('), _key('ln', insert: 'ln('), _key('log', insert: 'log(')]),
                _row([_key('π'), _key('e'), _key('^'), _key('!'), _key('Ans')]),
                _row([_key('('), _key(')'), _key('%'), _key('⌫', onTap: _backspace), _key('C', onTap: _clear)]),
                _row([_key('7'), _key('8'), _key('9'), _key('÷'), _key('abs', insert: 'abs(')]),
                _row([_key('4'), _key('5'), _key('6'), _key('×'), _key('exp', insert: 'exp(')]),
                _row([_key('1'), _key('2'), _key('3'), _key('−'), _key('cbrt', insert: 'cbrt(')]),
                _row([_key('0'), _key('.'), _key('+'), _key('=', onTap: _equals, strong: true), _key('1/x', insert: '1/(')]),
              ]),
            ),
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('سابقه', style: TextStyle(fontWeight: FontWeight.w800)),
              for (final h in _history)
                ListTile(
                  dense: true,
                  title: Directionality(textDirection: TextDirection.ltr, child: Text(h, textAlign: TextAlign.left)),
                  onTap: () => _insert(h.split(' = ').last),
                ),
            ],
            const SizedBox(height: 6),
            Text(
              'ارقام فارسی هم پذیرفته می‌شود. زاویه‌ها در حالت ${_degrees ? 'درجه' : 'رادیان'} حساب می‌شوند.${_ans == 0 ? '' : ' پاسخ قبلی: ${fa(formatResult(_ans))}'}',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}
