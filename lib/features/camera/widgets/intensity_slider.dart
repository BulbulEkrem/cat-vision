import 'package:flutter/material.dart';

/// Slider to control the intensity of the cat vision filter.
class IntensitySlider extends StatelessWidget {
  const IntensitySlider({
    super.key,
    required this.value,
    required this.onChanged,
    required this.visible,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !visible,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.visibility_off, color: Colors.white54, size: 18),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF7CFC00),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFF7CFC00),
                    overlayColor:
                        const Color(0xFF7CFC00).withValues(alpha: 0.2),
                    trackHeight: 3,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: value,
                    onChanged: onChanged,
                  ),
                ),
              ),
              const Icon(Icons.pets, color: Colors.white54, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
