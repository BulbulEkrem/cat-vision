import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kedigoz/features/filters/filter_engine.dart';

/// A widget that applies cat vision filters over its [child].
///
/// Layers applied (bottom to top):
/// 1. Dichromatic color transformation via ColorFiltered
/// 2. Tapetum lucidum brightness boost via ColorFiltered
/// 3. Reduced acuity via ImageFiltered (Gaussian blur)
/// 4. Peripheral vignette via a radial gradient overlay
class CatVisionFilter extends StatelessWidget {
  const CatVisionFilter({
    super.key,
    required this.child,
    required this.intensity,
    required this.enabled,
  });

  final Widget child;

  /// Filter intensity from 0.0 to 1.0.
  final double intensity;

  /// Whether the cat vision filter is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled || intensity == 0.0) return child;

    final colorMatrix = FilterEngine.catVisionColorMatrix(intensity);
    final brightness = FilterEngine.tapetumLucidumBrightness(intensity);
    final blurSigma = FilterEngine.blurSigma(intensity);
    final vignetteAmount = FilterEngine.vignetteIntensity(intensity);

    Widget result = child;

    // 1. Dichromatic color transformation
    result = ColorFiltered(
      colorFilter: ColorFilter.matrix(colorMatrix),
      child: result,
    );

    // 2. Tapetum lucidum brightness boost
    // Brightness matrix: scale RGB channels
    result = ColorFiltered(
      colorFilter: ColorFilter.matrix(<double>[
        brightness, 0, 0, 0, 0, //
        0, brightness, 0, 0, 0, //
        0, 0, brightness, 0, 0, //
        0, 0, 0, 1, 0, //
      ]),
      child: result,
    );

    // 3. Reduced acuity (slight blur)
    if (blurSigma > 0.01) {
      result = ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: blurSigma,
          sigmaY: blurSigma,
          tileMode: TileMode.clamp,
        ),
        child: result,
      );
    }

    // 4. Vignette overlay
    if (vignetteAmount > 0.01) {
      result = Stack(
        fit: StackFit.expand,
        children: [
          result,
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: vignetteAmount),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return result;
  }
}
