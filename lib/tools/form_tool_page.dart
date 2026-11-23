import 'package:flutter/material.dart';

import '../core/ads.dart';
import '../core/engtools.dart';
import '../core/numbers.dart';
import '../core/format.dart';

/// A page for a [FormTool], or for a family of them chosen from a dropdown
/// (such as the geometric shapes).
class FormToolPage extends StatefulWidget {
  const FormToolPage({super.key, required this.title, required this.tools, this.intro});

  final String title;
  final List<FormTool> tools;
  final String? intro;

  @override
  State<FormToolPage> createState() => _FormToolPageState();
}

class _FormToolPageState extends State<FormToolPage> {
  late FormTool _tool = widget.tools.first;
  final Map<String, TextEditingController> _c = {};
  List<ResultRow>? _rows;
  String? _error;

  @override
  void initState() {
    super.initState();
    _rebuildControllers();
  }

  void _rebuildControllers() {
    for (final c in _c.values) {
      c.dispose();
    }
    _c.clear();
    for (final field in _tool.fields) {
      _c[field.key] = TextEditingController(text: field.initial);
    }
    _rows = null;
    _error = null;
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _calculate() {
    try {
      final values = <String, double>{};
      for (final field in _tool.fields) {
        values[field.key] = parseEstimateNumber(_c[field.key]!.text, label: field.label, allowZero: field.allowZero);
      }
      final rows = _tool.compute(values);
      setState(() {
        _rows = rows;
        _error = null;
      });
    } on FormatException catch (e) {
      setState(() {
        _error = e.message;
        _rows = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.intro != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(widget.intro!, style: TextStyle(color: scheme.secondary, height: 1.7))),
            if (widget.tools.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DropdownButtonFormField<FormTool>(
                  key: const Key('tool-select'),
                  initialValue: _tool,
                  decoration: const InputDecoration(labelText: 'نوع'),
                  items: [for (final t in widget.tools) DropdownMenuItem(value: t, child: Text(t.title))],
                  onChanged: (t) {
                    if (t == null) return;
                    setState(() {
                      _tool = t;
                      _rebuildControllers();
                    });
                  },
                ),
              ),
            if (_tool.description.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(_tool.description)),
            for (final field in _tool.fields)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TextField(
                  key: Key('f-${field.key}'),
                  controller: _c[field.key],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: field.label, suffixText: field.unit),
                ),
              ),
            FilledButton.icon(
              key: const Key('calc'),
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('محاسبه'),
            ),
            if (_error != null)
              Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, key: const Key('tool-error'), style: TextStyle(color: scheme.error))),
            if (_rows != null) ...[
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    for (final r in _rows!)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Expanded(child: Text(r.label)),
                          Text('${fa(r.value)} ${r.unit}'.trim(), style: const TextStyle(fontWeight: FontWeight.w800)),
                        ]),
                      ),
                  ]),
                ),
              ),
            ],
            if (_tool.note != null)
              Padding(padding: const EdgeInsets.only(top: 12), child: Text(_tool.note!, style: TextStyle(fontSize: 12, color: scheme.secondary, height: 1.7))),
            const AdSlot(),
          ],
        ),
      ),
    );
  }
}
