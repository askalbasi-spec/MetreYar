import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'core/daily_tip.dart';
import 'core/jalali.dart';

/// The app mark: three rising bars (quantities) and a level bubble that
/// drifts to the centre and settles. It plays once on start and loops
/// gently.
class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key, this.size = 72});
  final double size;

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(size: Size.square(widget.size), painter: LogoPainter(_c.value)),
      );
}

class LogoPainter extends CustomPainter {
  LogoPainter(this.t);

  /// 0..1 loop position.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final bg = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * .22));
    canvas.drawRRect(bg, Paint()..shader = const LinearGradient(colors: [Color(0xFF16294A), Color(0xFF0B1730)], begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Offset.zero & size));
    canvas.drawRRect(bg, Paint()..style = PaintingStyle.stroke..strokeWidth = s * .02..color = const Color(0xFFD6AD55));

    // Bars grow one after another during the first 45% of the loop and
    // then breathe slightly.
    const heights = [.28, .40, .50];
    for (var i = 0; i < 3; i++) {
      final start = i * .12;
      final grow = Curves.easeOutBack.transform(((t / .45) - start / .45).clamp(0.0, 1.0));
      final breathe = t > .45 ? 1 + .03 * math.sin((t - .45) / .55 * 2 * math.pi + i) : 1.0;
      final h = s * heights[i] * grow * breathe;
      final x = s * (.2 + i * .22);
      final r = RRect.fromRectAndRadius(Rect.fromLTWH(x, s * .78 - h, s * .16, h), Radius.circular(s * .04));
      canvas.drawRRect(r, Paint()..color = Color.lerp(const Color(0xFFB8913C), const Color(0xFFF1D58C), i / 2)!);
    }
    // Ground line.
    canvas.drawLine(Offset(s * .14, s * .8), Offset(s * .86, s * .8), Paint()..color = Colors.white70..strokeWidth = s * .02..strokeCap = StrokeCap.round);

    // Level vial at the top with a bubble that swings and settles.
    final vial = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(s * .5, s * .2), width: s * .5, height: s * .12), Radius.circular(s * .06));
    canvas.drawRRect(vial, Paint()..style = PaintingStyle.stroke..strokeWidth = s * .02..color = Colors.white);
    final swing = math.exp(-t * 4) * math.cos(t * 4 * math.pi);
    final loop = t > .5 ? .03 * math.sin((t - .5) * 2 * math.pi * 2) : 0.0;
    final bx = s * .5 + s * .17 * (swing + loop);
    canvas.drawCircle(Offset(bx, s * .2), s * .045, Paint()..color = const Color(0xFF7CFFB2));
  }

  @override
  bool shouldRepaint(LogoPainter old) => old.t != t;
}

/// The "tip of the day" card: it changes every day and plays a small entry
/// animation (a glowing bulb and the text sliding in).
class DailyTipCard extends StatefulWidget {
  const DailyTipCard({super.key, DateTime? now}) : _now = now;
  final DateTime? _now;

  @override
  State<DailyTipCard> createState() => _DailyTipCardState();
}

class _DailyTipCardState extends State<DailyTipCard> with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  late final AnimationController _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))..repeat(reverse: true);

  @override
  void dispose() {
    _in.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = widget._now ?? DateTime.now();
    final tip = tipForDate(now);
    final slide = CurvedAnimation(parent: _in, curve: Curves.easeOutCubic);
    return Container(
      key: const Key('daily-tip'),
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB477),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFFFD18D), width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: FadeTransition(
        opacity: slide,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, .25), end: Offset.zero).animate(slide),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              AnimatedBuilder(
                animation: _glow,
                builder: (context, _) => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.yellowAccent.withValues(alpha: .25 + .5 * _glow.value), blurRadius: 6 + 10 * _glow.value)],
                  ),
                  child: const Icon(Icons.lightbulb, color: Color(0xFF172033), size: 22),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(child: Text('نکته اجرایی امروز', style: TextStyle(color: Color(0xFF172033), fontSize: 17, fontWeight: FontWeight.w900))),
              Text(Jalali.fromDate(now).formatLong(), style: const TextStyle(color: Color(0xFF172033), fontSize: 11)),
            ]),
            const SizedBox(height: 8),
            Text(tip, key: const Key('daily-tip-text'), style: const TextStyle(color: Color(0xFF172033), height: 1.8, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}
