import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metreyar/core/daily_tip.dart';
import 'package:metreyar/core/economy.dart';
import 'package:metreyar/core/engtools.dart';
import 'package:metreyar/core/units.dart';
import 'package:metreyar/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

UnitCategory cat(String name) => unitCategories.firstWhere((c) => c.name == name);

void main() {
  group('units', () {
    test('length, area, volume', () {
      expect(convertUnit(cat('طول'), 'm', 'cm', 1), closeTo(100, 1e-9));
      expect(convertUnit(cat('طول'), 'in', 'mm', 1), closeTo(25.4, 1e-9));
      expect(convertUnit(cat('مساحت'), 'ha', 'm2', 1), closeTo(10000, 1e-9));
      expect(convertUnit(cat('حجم'), 'm3', 'L', 2), closeTo(2000, 1e-9));
    });
    test('pressure and speed', () {
      expect(convertUnit(cat('فشار و تنش'), 'MPa', 'kgfcm2', 1), closeTo(10.1972, 1e-3));
      expect(convertUnit(cat('فشار و تنش'), 'atm', 'kPa', 1), closeTo(101.325, 1e-9));
      expect(convertUnit(cat('سرعت'), 'kmh', 'ms', 36), closeTo(10, 1e-9));
    });
    test('temperature', () {
      final t = cat('دما');
      expect(convertUnit(t, 'C', 'F', 100), closeTo(212, 1e-9));
      expect(convertUnit(t, 'F', 'C', 32), closeTo(0, 1e-9));
      expect(convertUnit(t, 'K', 'C', 0), closeTo(-273.15, 1e-9));
      expect(() => convertUnit(t, 'C', 'K', -300), throwsFormatException);
    });
    test('every category has distinct unit keys and positive factors', () {
      for (final c in unitCategories) {
        expect(c.units.map((u) => u.key).toSet().length, c.units.length, reason: c.name);
        for (final u in c.units) {
          expect(u.factor > 0, isTrue);
        }
      }
      expect(unitCategories.length >= 10, isTrue);
    });
    test('formatUnitValue', () {
      expect(formatUnitValue(100.0), '100');
      expect(formatUnitValue(0.5), '0.5');
      expect(formatUnitValue(1e-9).contains('e'), isTrue);
    });
  });

  group('engineering tools', () {
    test('geometry', () {
      expect(rectangle(2, 3).first.value, '6');
      expect(triangle(3, 4, 5).first.value, '6');
      expect(() => triangle(1, 2, 5), throwsFormatException);
      expect(circle(2).first.value, f(math.pi));
      expect(cylinder(1, 2).first.value, f(math.pi / 4 * 2));
      expect(sphere(2).first.value, f(4 / 3 * math.pi));
    });
    test('simple beam', () {
      final rows = simpleBeam(10, 0, 4, 200, 10000);
      expect(rows[0].value, '20'); // reaction
      expect(rows[2].value, '20'); // M = wL²/8
      expect(rows[3].value, '1.67'); // deflection mm
      expect(() => simpleBeam(0, 0, 4, 200, 10000), throwsFormatException);
    });
    test('stairs', () {
      final r = stairs(300, 28, 17);
      expect(r[0].value, '18');
      expect(r[1].value, '16.67');
    });
    test('concrete mix', () {
      final r = concreteMix(350, 0.45, 45, 1);
      expect(r[0].value, '350');
      expect(r[1].value, '7');
      expect(r[2].value, '157.5');
      expect(() => concreteMix(350, 0.45, 100, 1), throwsFormatException);
    });
    test('survey', () {
      final r = distanceAzimuth(0, 0, 30, 40);
      expect(r.distance, 50);
      expect(r.azimuthDeg, closeTo(36.8699, 1e-4));
      expect(distanceAzimuth(0, 0, -1, 0).azimuthDeg, 270);
      expect(toDms(36.8699), startsWith('36°'));
      final p = polygonAreaPerimeter([[0, 0], [10, 0], [10, 5], [0, 5]]);
      expect(p.area, 50);
      expect(p.perimeter, 30);
      expect(() => polygonAreaPerimeter([[0, 0], [1, 1]]), throwsFormatException);
    });
  });

  group('daily tip', () {
    test('stable within a day, changes the next day', () {
      final a = tipForDate(DateTime(2026, 11, 23, 8));
      expect(tipForDate(DateTime(2026, 11, 23, 22)), a);
      expect(tipForDate(DateTime(2026, 11, 24, 8)), isNot(a));
    });
    test('cycles through all tips', () {
      final seen = {for (var d = 0; d < dailyTips.length; d++) tipForDate(DateTime(2026, 1, 1 + d))};
      expect(seen.length, dailyTips.length);
    });
  });

  group('app shell', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<void> openApp(WidgetTester tester) async {
      tester.view.physicalSize = const Size(900, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MetreYarApp(economy: Economy()));
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('settings opens, changes theme and edits the profile', (tester) async {
      await openApp(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('تنظیمات برنامه'), findsOneWidget);

      await tester.tap(find.byKey(const Key('theme-blueprint')));
      await tester.pump(const Duration(milliseconds: 400));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('themeKey'), 'blueprint');

      await tester.tap(find.byKey(const Key('settings-profile')));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.enterText(find.byType(TextField).at(0), 'علی');
      await tester.enterText(find.byType(TextField).at(1), 'رضایی');
      await tester.tap(find.text('ذخیره مشخصات'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(prefs.getString('profile.firstName'), 'علی');
    });

    testWidgets('profile card on the home page opens the editor and shows the name', (tester) async {
      await openApp(tester);
      await tester.tap(find.text('مهندس گرامی، خوش آمدید'));
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('پروفایل کاربر'), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'سارا');
      await tester.tap(find.text('ذخیره مشخصات'));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 800));
      expect(find.textContaining('سارا'), findsWidgets);
    });

    testWidgets('home shows ten engineering tools and the daily tip', (tester) async {
      await openApp(tester);
      for (final t in [
        'ماشین‌حساب مهندسی', 'دفتر ترازیابی (نیوو)', 'تراز دیجیتال و شیب‌سنج', 'صورت‌مقادیر و برآورد', 'تبدیل واحد',
        'هندسه: مساحت و حجم', 'تیر: لنگر و خیز', 'پلکان', 'مصالح بتن', 'نقشه‌برداری و آزیموت',
      ]) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(find.byKey(const Key('daily-tip-text')), findsOneWidget);
    });

    testWidgets('converter converts across categories', (tester) async {
      await openApp(tester);
      await tester.tap(find.text('تبدیل واحد'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.enterText(find.byKey(const Key('conv-input')), '۵');
      await tester.pump();
      expect(find.byKey(const Key('conv-result')), findsOneWidget);
      expect(tester.widget<SelectableText>(find.byKey(const Key('conv-result'))).data, contains('۵۰۰'));
      await tester.tap(find.byKey(const Key('cat-دما')));
      await tester.pump();
      await tester.enterText(find.byKey(const Key('conv-input')), '100');
      await tester.pump();
      expect(tester.widget<SelectableText>(find.byKey(const Key('conv-result'))).data, contains('۲۱۲'));
    });
  });
}
