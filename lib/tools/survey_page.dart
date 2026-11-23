import 'package:flutter/material.dart';

import '../core/engtools.dart';
import '../core/format.dart';
import '../core/numbers.dart';

/// Survey helpers: distance and azimuth between two points, and area and
/// perimeter of a polygon from its coordinates.
class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final _x1 = TextEditingController(text: '0');
  final _y1 = TextEditingController(text: '0');
  final _x2 = TextEditingController(text: '30');
  final _y2 = TextEditingController(text: '40');
  final _poly = TextEditingController(text: '0 0\n10 0\n10 5\n0 5');
  String? _daResult, _daError, _polyResult, _polyError;

  @override
  void dispose() {
    for (final c in [_x1, _y1, _x2, _y2, _poly]) {
      c.dispose();
    }
    super.dispose();
  }

  double _n(TextEditingController c, String label) {
    final t = c.text.trim();
    final neg = t.startsWith('-') || t.startsWith('−');
    final v = parseEstimateNumber(neg ? t.substring(1) : t, label: label, allowZero: true);
    return neg ? -v : v;
  }

  void _distance() {
    try {
      final r = distanceAzimuth(_n(_x1, 'X1'), _n(_y1, 'Y1'), _n(_x2, 'X2'), _n(_y2, 'Y2'));
      if (r.distance == 0) throw const FormatException('دو نقطه بر هم منطبق‌اند.');
      setState(() {
        _daResult = 'ΔX = ${f(r.dx)}   ΔY = ${f(r.dy)}\nفاصله افقی = ${f(r.distance)}\nآزیموت = ${f(r.azimuthDeg, 4)}° = ${toDms(r.azimuthDeg)}';
        _daError = null;
      });
    } on FormatException catch (e) {
      setState(() {
        _daError = e.message;
        _daResult = null;
      });
    }
  }

  void _polygon() {
    try {
      final pts = <List<double>>[];
      for (final line in _poly.text.split('\n')) {
        final t = line.trim();
        if (t.isEmpty) continue;
        final parts = t.split(RegExp(r'[\s,;،]+')).where((e) => e.isNotEmpty).toList();
        if (parts.length != 2) throw FormatException('هر خط باید دو عدد (X و Y) داشته باشد: «$t»');
        double p(String s) {
          final neg = s.startsWith('-') || s.startsWith('−');
          final v = parseEstimateNumber(neg ? s.substring(1) : s, label: 'مختصات', allowZero: true);
          return neg ? -v : v;
        }
        pts.add([p(parts[0]), p(parts[1])]);
      }
      final r = polygonAreaPerimeter(pts);
      setState(() {
        _polyResult = 'مساحت = ${f(r.area)}\nمحیط = ${f(r.perimeter)}\nتعداد نقاط = ${pts.length}';
        _polyError = null;
      });
    } on FormatException catch (e) {
      setState(() {
        _polyError = e.message;
        _polyResult = null;
      });
    }
  }

  Widget _field(TextEditingController c, String l) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), decoration: InputDecoration(labelText: l)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('نقشه‌برداری: فاصله، آزیموت، مساحت')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('فاصله و آزیموت دو نقطه', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(children: [_field(_x1, 'X۱ (شرقی)'), _field(_y1, 'Y۱ (شمالی)')]),
            const SizedBox(height: 8),
            Row(children: [_field(_x2, 'X۲ (شرقی)'), _field(_y2, 'Y۲ (شمالی)')]),
            const SizedBox(height: 8),
            FilledButton(key: const Key('da-calc'), onPressed: _distance, child: const Text('محاسبه فاصله و آزیموت')),
            if (_daError != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_daError!, style: TextStyle(color: scheme.error))),
            if (_daResult != null) Card(child: Padding(padding: const EdgeInsets.all(14), child: SelectableText(fa(_daResult!), key: const Key('da-result'), style: const TextStyle(height: 1.8, fontWeight: FontWeight.w700)))),
            const Divider(height: 32),
            const Text('مساحت و محیط چندضلعی از مختصات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('هر خط یک نقطه: X و Y با فاصله. نقاط را به ترتیب دور زمین بنویسید.', style: TextStyle(color: scheme.secondary, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(controller: _poly, minLines: 4, maxLines: 10, keyboardType: TextInputType.multiline, decoration: const InputDecoration(labelText: 'مختصات نقاط')),
            const SizedBox(height: 8),
            FilledButton(key: const Key('poly-calc'), onPressed: _polygon, child: const Text('محاسبه مساحت')),
            if (_polyError != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_polyError!, style: TextStyle(color: scheme.error))),
            if (_polyResult != null) Card(child: Padding(padding: const EdgeInsets.all(14), child: SelectableText(fa(_polyResult!), key: const Key('poly-result'), style: const TextStyle(height: 1.8, fontWeight: FontWeight.w700)))),
          ],
        ),
      ),
    );
  }
}
