import 'package:flutter_test/flutter_test.dart';
import 'package:kedigoz/features/filters/filter_engine.dart';

void main() {
  group('FilterEngine', () {
    test('identity matrix at intensity 0', () {
      final matrix = FilterEngine.catVisionColorMatrix(0.0);
      // Should be identity: R=1,0,0,0,0 / G=0,1,0,0,0 / B=0,0,1,0,0 / A=0,0,0,1,0
      expect(matrix[0], 1.0); // R->R
      expect(matrix[6], 1.0); // G->G
      expect(matrix[12], 1.0); // B->B
      expect(matrix[18], 1.0); // A->A
    });

    test('full cat matrix at intensity 1', () {
      final matrix = FilterEngine.catVisionColorMatrix(1.0);
      // Red channel should be reduced
      expect(matrix[0], lessThan(1.0));
      // Blue channel should be preserved
      expect(matrix[12], greaterThan(0.8));
    });

    test('blur sigma scales with intensity', () {
      expect(FilterEngine.blurSigma(0.0), 0.0);
      expect(FilterEngine.blurSigma(1.0), 1.2);
      expect(FilterEngine.blurSigma(0.5), closeTo(0.6, 0.01));
    });

    test('brightness boost scales with intensity', () {
      expect(FilterEngine.tapetumLucidumBrightness(0.0), 1.0);
      expect(FilterEngine.tapetumLucidumBrightness(1.0), closeTo(1.15, 0.01));
    });
  });
}
