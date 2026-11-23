import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:metreyar/core/boq.dart';
import 'package:metreyar/core/estimate_engine.dart';
import 'package:metreyar/core/expr.dart';
import 'package:metreyar/core/inclination.dart';
import 'package:metreyar/core/leveling.dart';
import 'package:metreyar/core/numbers.dart';

double _eval(String s, {bool deg = true, double ans = 0}) =>
    ExprEvaluator(degrees: deg, ans: ans).evaluate(s);

void main() {
  group('expression evaluator', () {
    test('precedence and parentheses', () {
      expect(_eval('2+3*4'), 14);
      expect(_eval('(2+3)*4'), 20);
      expect(_eval('2^3^2'), 512);
      expect(_eval('-2^2'), -4);
      expect(_eval('10/4'), 2.5);
    });
    test('persian digits and operators', () {
      expect(_eval('۱۲×۳'), 36);
      expect(_eval('۹÷۳'), 3);
      expect(_eval('۱٫۵+۱'), 2.5);
    });
    test('functions in degrees and radians', () {
      expect(_eval('sin(30)'), closeTo(0.5, 1e-12));
      expect(_eval('cos(60)'), closeTo(0.5, 1e-12));
      expect(_eval('sin(180)'), 0);
      expect(_eval('atan(1)'), closeTo(45, 1e-9));
      expect(_eval('sin(π/2)', deg: false), closeTo(1, 1e-12));
    });
    test('constants, implicit multiplication, factorial, percent, Ans', () {
      expect(_eval('2π'), closeTo(2 * math.pi, 1e-12));
      expect(_eval('3(4+1)'), 15);
      expect(_eval('5!'), 120);
      expect(_eval('50%'), 0.5);
      expect(_eval('Ans*2', ans: 21), 42);
      expect(_eval('sqrt(16)+ln(e)+log(100)'), closeTo(7, 1e-12));
    });
    test('errors are reported in Persian', () {
      for (final bad in ['', '2+', '(2', '1/0', 'sqrt(-1)', 'foo(2)', '2 \$ 3', 'asin(2)', '()']) {
        expect(() => _eval(bad), throwsA(isA<ExprException>()), reason: bad);
      }
    });
    test('formatResult trims noise', () {
      expect(formatResult(14), '14');
      expect(formatResult(0.1 + 0.2), '0.3');
      expect(formatResult(2.5), '2.5');
    });
  });

  group('leveling', () {
    // BM 100.000: BS 1.500 -> TP1 FS 0.800 BS 1.200 -> end FS 2.000
    test('height of instrument', () {
      final rows = [
        LevelRow(label: 'BM', bs: 1.5),
        LevelRow(label: 'A', isr: 1.0),
        LevelRow(label: 'TP1', fs: 0.8, bs: 1.2),
        LevelRow(label: 'End', fs: 2.0),
      ];
      final r = reduceLevels(rows, 100);
      expect(r.rl[0], 100);
      expect(r.rl[1], closeTo(100.5, 1e-9));
      expect(r.rl[2], closeTo(100.7, 1e-9));
      expect(r.rl[3], closeTo(99.9, 1e-9));
      expect(r.sumBs, closeTo(2.7, 1e-9));
      expect(r.sumFs, closeTo(2.8, 1e-9));
      expect(r.arithmeticOk, isTrue);
      expect(r.lastRl, closeTo(99.9, 1e-9));
    });
    test('misclosure and allowable', () {
      expect(misclosureMm(100.012, 100.0), closeTo(12, 1e-6));
      expect(allowableMisclosureMm(4), closeTo(20, 1e-9));
      final c = equalCorrections(2, 0.010);
      expect(c.length, 2);
      expect(c.last, closeTo(-0.010, 1e-12));
    });
  });

  group('inclination', () {
    test('flat phone reads zero', () {
      final t = flatTilt(0, 0, 9.81);
      expect(t.pitch, closeTo(0, 1e-9));
      expect(t.roll, closeTo(0, 1e-9));
    });
    test('upright edge angle and slope', () {
      expect(edgeInclinationDeg(0, 9.81), closeTo(0, 1e-9));
      expect(edgeInclinationDeg(9.81 * math.sin(math.pi / 12), 9.81 * math.cos(math.pi / 12)), closeTo(15, 1e-6));
      expect(slopePercent(45), closeTo(100, 1e-9));
    });
  });

  group('boq', () {
    test('total and tsv', () {
      final items = [
        BoqItem(id: '1', title: 'بتن', unit: 'مترمکعب', qty: 2, unitPrice: 1000),
        BoqItem(id: '2', title: 'آرماتور', unit: 'کیلوگرم', qty: 1.5, unitPrice: 200),
      ];
      expect(boqTotal(items), 2300);
      final tsv = boqToTsv(items);
      expect(tsv.split('\n').length, 4);
      expect(tsv, contains('2300'));
    });
    test('quantity is read from an estimate result', () {
      final q = parseResultQuantity('12.500 مترمکعب بتن');
      expect(q, isNotNull);
      expect(q!.qty, 12.5);
      expect(q.unit, 'مترمکعب');
      expect(parseResultQuantity('بدون عدد'), isNull);
    });
  });

  group('numbers and estimates', () {
    test('formatToman groups with Persian digits', () {
      expect(formatToman(1234567), '۱٬۲۳۴٬۵۶۷');
    });
    double Function(String, {bool allowZero}) inputs(Map<String, double> m) =>
        (k, {bool allowZero = false}) {
          final v = m[k];
          if (v == null) throw FormatException('missing $k');
          return v;
        };
    test('beam volume', () {
      final r = computeEstimate(51, inputs({'length': 2, 'width': 3, 'height': 4}));
      expect(r, startsWith('24.000'));
    });
    test('cylinder concrete', () {
      final r = computeEstimate(13, inputs({'diameter': 1, 'height': 2}));
      expect(r, contains((math.pi / 4 * 2).toStringAsFixed(3)));
    });
    test('rebar weight per metre', () {
      final r = computeEstimate(1, inputs({'diameter': 16, 'length': 12}));
      expect(r, startsWith((16 * 16 / 162 * 12).toStringAsFixed(2)));
    });
    test('missing input throws', () {
      expect(() => computeEstimate(51, inputs({'length': 1})), throwsFormatException);
    });
  });
}
