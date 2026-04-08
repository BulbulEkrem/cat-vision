/// Defines the cat vision filter parameters and color matrix calculations.
///
/// Cats are dichromats — they see primarily in blue-violet and yellow-green,
/// with reduced sensitivity to red and green. This engine simulates that
/// by transforming the color space accordingly.
class FilterEngine {
  const FilterEngine._();

  /// Generates a 5x20 color matrix that simulates cat dichromatic vision.
  ///
  /// [intensity] ranges from 0.0 (no filter / human vision) to 1.0 (full cat vision).
  ///
  /// The matrix format matches what ColorFilter.matrix() expects:
  /// [R, G, B, A, offset] for each of R, G, B, A output channels (row-major).
  static List<double> catVisionColorMatrix(double intensity) {
    // Identity matrix (human vision)
    const identity = <double>[
      1, 0, 0, 0, 0, //
      0, 1, 0, 0, 0, //
      0, 0, 1, 0, 0, //
      0, 0, 0, 1, 0, //
    ];

    // Cat dichromatic simulation matrix:
    // - Red channel: reduce red, add some green contribution
    // - Green channel: reduce green, blend with red
    // - Blue channel: boost blue slightly, add yellow (R+G) reduction effect
    const catMatrix = <double>[
      0.50, 0.40, 0.10, 0, 0, // R output: muted, shifted toward yellow-green
      0.30, 0.50, 0.20, 0, 0, // G output: muted, blended
      0.05, 0.10, 0.85, 0, 8, // B output: preserved/boosted with slight offset
      0.00, 0.00, 0.00, 1, 0, // A output: unchanged
    ];

    // Lerp between identity and cat matrix based on intensity
    return List<double>.generate(20, (i) {
      return identity[i] + (catMatrix[i] - identity[i]) * intensity;
    });
  }

  /// Returns the brightness boost factor for tapetum lucidum simulation.
  /// Cats' eyes reflect light, giving them better low-light vision.
  static double tapetumLucidumBrightness(double intensity) {
    // Up to 15% brightness boost at full intensity
    return 1.0 + (0.15 * intensity);
  }

  /// Returns the blur sigma for reduced acuity simulation.
  /// Cats have ~20/100-20/200 vision compared to human 20/20.
  static double blurSigma(double intensity) {
    // Up to 1.2 sigma Gaussian blur at full intensity
    return 1.2 * intensity;
  }

  /// Returns the vignette intensity for peripheral vision simulation.
  /// Cats have wider field of view (200° vs 180°) but less peripheral acuity.
  static double vignetteIntensity(double intensity) {
    return 0.6 * intensity;
  }
}
