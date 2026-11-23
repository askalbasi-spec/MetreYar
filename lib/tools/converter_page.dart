import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/numbers.dart';
import '../core/units.dart';

/// Converter for every unit category. Used as a page and inside the
/// workspace tab.
class ConverterBody extends StatefulWidget {
  const ConverterBody({super.key});

  @override
  State<ConverterBody> createState() => _ConverterBodyState();
}

class _ConverterBodyState extends State<ConverterBody> {
  final _input = TextEditingController(text: '1');
  UnitCategory _cat = unitCategories.first;
  late String _from = _cat.units[0].key;
  late String _to = _cat.units[1].key;
  String? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _input.addListener(_convert);
    _convert();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _setCategory(UnitCategory c) {
    _cat = c;
    _from = c.units[0].key;
    _to = c.units[c.units.length > 1 ? 1 : 0].key;
    _convert();
  }

  void _convert() {
    String? result, error;
    final text = _input.text.trim();
    if (text.isEmpty) {
      error = null;
    } else {
      try {
        final negative = text.startsWith('-') || text.startsWith('−');
        var v = parseEstimateNumber(negative ? text.substring(1) : text, label: 'مقدار', allowZero: true);
        if (negative) v = -v;
        if (negative && !_cat.isTemperature) {
          throw const FormatException('در این دسته مقدار منفی معنا ندارد.');
        }
        result = formatUnitValue(convertUnit(_cat, _from, _to, v));
      } on FormatException catch (e) {
        error = e.message;
      }
    }
    if (mounted) setState(() {
      _result = result;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('تبدیل واحدهای مهندسی', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in unitCategories)
              ChoiceChip(
                key: Key('cat-${c.name}'),
                label: Text(c.name),
                selected: c == _cat,
                onSelected: (_) => setState(() => _setCategory(c)),
              ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          key: const Key('conv-input'),
          controller: _input,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          decoration: const InputDecoration(labelText: 'مقدار'),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          key: ValueKey('from-${_cat.name}-$_from'),
          initialValue: _from,
          decoration: const InputDecoration(labelText: 'از واحد'),
          items: [for (final u in _cat.units) DropdownMenuItem(value: u.key, child: Text(u.name))],
          onChanged: (v) {
            if (v != null) {
              _from = v;
              _convert();
            }
          },
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              key: ValueKey('to-${_cat.name}-$_to'),
              initialValue: _to,
              decoration: const InputDecoration(labelText: 'به واحد'),
              items: [for (final u in _cat.units) DropdownMenuItem(value: u.key, child: Text(u.name))],
              onChanged: (v) {
                if (v != null) {
                  _to = v;
                  _convert();
                }
              },
            ),
          ),
          IconButton(
            tooltip: 'جابه‌جایی',
            icon: const Icon(Icons.swap_vert),
            onPressed: () {
              final t = _from;
              _from = _to;
              _to = t;
              _convert();
            },
          ),
        ]),
        const SizedBox(height: 14),
        if (_error != null) Text(_error!, key: const Key('conv-error'), style: TextStyle(color: scheme.error)),
        if (_result != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                '${fa(_result!)} ${_cat.unit(_to).name}',
                key: const Key('conv-result'),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.6),
              ),
            ),
          ),
      ],
    );
  }
}

class ConverterPage extends StatelessWidget {
  const ConverterPage({super.key});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(appBar: AppBar(title: const Text('تبدیل واحد')), body: const ConverterBody()),
      );
}
