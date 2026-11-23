import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../core/format.dart';
import '../core/inclination.dart';

/// Phone spirit level and inclinometer using the accelerometer.
class LevelPage extends StatefulWidget {
  const LevelPage({super.key});

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  StreamSubscription<AccelerometerEvent>? _sub;
  double _x = 0, _y = 0, _z = 9.8;
  double _offsetPitch = 0, _offsetRoll = 0, _offsetEdge = 0;
  bool _flat = true;
  bool _hasData = false;

  @override
  void initState() {
    super.initState();
    try {
      _sub = accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval).listen((e) {
        // Light low-pass filter to calm the reading.
        const a = 0.2;
        setState(() {
          _x += a * (e.x - _x);
          _y += a * (e.y - _y);
          _z += a * (e.z - _z);
          _hasData = true;
        });
      }, onError: (Object _) {});
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _calibrate() {
    setState(() {
      if (_flat) {
        final t = flatTilt(_x, _y, _z);
        _offsetPitch = t.pitch;
        _offsetRoll = t.roll;
      } else {
        _offsetEdge = edgeInclinationDeg(_x, _y);
      }
    });
  }

  void _resetCalibration() => setState(() {
        _offsetPitch = _offsetRoll = _offsetEdge = 0;
      });

  @override
  Widget build(BuildContext context) {
    final t = flatTilt(_x, _y, _z);
    final pitch = t.pitch - _offsetPitch;
    final roll = t.roll - _offsetRoll;
    final edge = edgeInclinationDeg(_x, _y) - _offsetEdge;
    final angle = _flat ? math.sqrt(pitch * pitch + roll * roll) : edge.abs();
    final level = angle < 0.5;
    final scheme = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تراز دیجیتال و شیب‌سنج')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('گوشی روی سطح'), icon: Icon(Icons.stay_current_landscape)),
                ButtonSegment(value: false, label: Text('گوشی ایستاده'), icon: Icon(Icons.stay_current_portrait)),
              ],
              selected: {_flat},
              onSelectionChanged: (s) => setState(() => _flat = s.first),
            ),
            const SizedBox(height: 16),
            if (!_hasData)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('در حال دریافت داده حسگر… اگر چیزی نمایش داده نشد، گوشی شما حسگر شتاب ندارد.'),
              ),
            Center(
              child: SizedBox(
                width: 260,
                height: 260,
                child: CustomPaint(
                  painter: _BubblePainter(
                    flat: _flat,
                    dx: _flat ? roll : edge,
                    dy: _flat ? pitch : 0,
                    color: level ? Colors.greenAccent : scheme.primary,
                    line: scheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Text(
                    level ? 'تراز است ✓' : '${fa(angle.toStringAsFixed(1))}°',
                    key: const Key('angle'),
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: level ? Colors.greenAccent : null),
                  ),
                  const SizedBox(height: 6),
                  Text('شیب: ${fa(slopePercent(angle).toStringAsFixed(1))}٪'),
                  if (_flat) Text('طولی ${fa(pitch.toStringAsFixed(1))}°   عرضی ${fa(roll.toStringAsFixed(1))}°'),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: FilledButton.icon(onPressed: _calibrate, icon: const Icon(Icons.adjust), label: const Text('صفر کردن (کالیبره)'))),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: _resetCalibration, child: const Text('بازنشانی')),
            ]),
            const SizedBox(height: 12),
            Text(
              'برای دقت بهتر، گوشی را روی سطح صاف و بدون قاب بگذارید و یک‌بار «صفر کردن» را بزنید. دقت این ابزار تقریبی است و جایگزین تراز و شیب‌سنج کارگاهی نیست.',
              style: TextStyle(fontSize: 12, color: scheme.secondary, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({required this.flat, required this.dx, required this.dy, required this.color, required this.line});
  final bool flat;
  final double dx, dy;
  final Color color, line;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 4;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = line.withValues(alpha: .7);
    if (flat) {
      canvas.drawCircle(c, r, stroke);
      canvas.drawCircle(c, r / 2, stroke);
      canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), stroke);
      canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), stroke);
      final scale = r / 15; // 15 degrees reaches the rim
      var ox = dx * scale, oy = -dy * scale;
      final len = math.sqrt(ox * ox + oy * oy);
      if (len > r - 16) {
        ox = ox / len * (r - 16);
        oy = oy / len * (r - 16);
      }
      canvas.drawCircle(c + Offset(ox, oy), 16, Paint()..color = color);
    } else {
      final w = size.width - 8;
      final tube = RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: w, height: 56), const Radius.circular(28));
      canvas.drawRRect(tube, stroke);
      canvas.drawLine(Offset(c.dx, c.dy - 28), Offset(c.dx, c.dy + 28), stroke);
      final scale = (w / 2 - 28) / 15;
      final ox = (dx * scale).clamp(-(w / 2 - 28), w / 2 - 28).toDouble();
      canvas.drawCircle(c + Offset(ox, 0), 18, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_BubblePainter old) => old.dx != dx || old.dy != dy || old.flat != flat || old.color != color;
}
