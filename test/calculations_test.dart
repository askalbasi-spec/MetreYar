import 'package:flutter_test/flutter_test.dart';
import 'package:metreyar/core/calculations.dart';

void main() {
  group('MetreYarCalculations', () {
    test('calculates rectangular concrete volume', () {
      expect(
        MetreYarCalculations.concreteVolume(lengthM: 5, widthM: 2, heightM: 0.3),
        closeTo(3, 0.000001),
      );
    });

    test('calculates approximate rebar weight', () {
      expect(
        MetreYarCalculations.rebarWeightKg(diameterMm: 16, totalLengthM: 12),
        closeTo(18.96296, 0.001),
      );
    });

    test('calculates rectangle area', () {
      expect(
        MetreYarCalculations.rectangleArea(lengthM: 4, widthM: 3),
        12,
      );
    });

    test('rejects zero or negative dimensions', () {
      expect(
        () => MetreYarCalculations.rectangleArea(lengthM: 0, widthM: 3),
        throwsArgumentError,
      );
    });
  });
}
