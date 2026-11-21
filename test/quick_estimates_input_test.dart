import 'package:flutter_test/flutter_test.dart';
import 'package:metreyar/quick_estimates.dart';

void main() {
  group('parseEstimateNumber', () {
    test('accepts Persian digits and decimal separator', () {
      expect(parseEstimateNumber('۱۲٫۵', label: 'طول'), 12.5);
    });

    test('accepts Arabic-Indic digits', () {
      expect(parseEstimateNumber('١٢٫٥', label: 'طول'), 12.5);
    });

    test('accepts grouped thousands and surrounding spaces', () {
      expect(parseEstimateNumber(' ۱٬۲۵۰ ', label: 'وزن'), 1250);
      expect(parseEstimateNumber('1,250', label: 'وزن'), 1250);
    });

    test('accepts comma as decimal separator', () {
      expect(parseEstimateNumber('12,5', label: 'ضخامت'), 12.5);
    });

    test('allows zero only for explicitly optional fields', () {
      expect(parseEstimateNumber('۰', label: 'پرت', allowZero: true), 0);
      expect(() => parseEstimateNumber('۰', label: 'مساحت'), throwsFormatException);
    });

    test('rejects empty, negative, and non-finite values with field label', () {
      expect(() => parseEstimateNumber('', label: 'طول'), throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('طول'))));
      expect(() => parseEstimateNumber('-2', label: 'عرض'), throwsFormatException);
      expect(() => parseEstimateNumber('NaN', label: 'ارتفاع'), throwsFormatException);
    });
  });
}
