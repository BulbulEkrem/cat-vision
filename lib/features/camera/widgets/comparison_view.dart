import 'package:flutter/material.dart';
import 'package:kedigoz/features/filters/cat_vision_filter.dart';

/// Split-screen comparison: left = human vision, right = cat vision.
/// A draggable divider in the middle lets the user adjust the split.
class ComparisonView extends StatefulWidget {
  const ComparisonView({
    super.key,
    required this.child,
    required this.filterIntensity,
  });

  /// The camera preview widget (unfiltered).
  final Widget child;

  /// Current filter intensity for the cat vision side.
  final double filterIntensity;

  @override
  State<ComparisonView> createState() => _ComparisonViewState();
}

class _ComparisonViewState extends State<ComparisonView> {
  double _dividerFraction = 0.5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final dividerX = width * _dividerFraction;

        return GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _dividerFraction =
                  (details.localPosition.dx / width).clamp(0.15, 0.85);
            });
          },
          child: Stack(
            children: [
              // Left side: human vision (no filter)
              Positioned.fill(
                child: ClipRect(
                  clipper: _LeftClipper(dividerX),
                  child: widget.child,
                ),
              ),

              // Right side: cat vision (filtered)
              Positioned.fill(
                child: ClipRect(
                  clipper: _RightClipper(dividerX),
                  child: CatVisionFilter(
                    intensity: widget.filterIntensity,
                    enabled: true,
                    child: widget.child,
                  ),
                ),
              ),

              // Divider line
              Positioned(
                left: dividerX - 1.5,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 3,
                  color: Colors.white,
                ),
              ),

              // Divider handle
              Positioned(
                left: dividerX - 20,
                top: height / 2 - 20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.drag_indicator,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
              ),

              // Labels
              Positioned(
                top: 12,
                left: 12,
                child: _Label('İnsan 👁️'),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _Label('Kedi 🐱'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LeftClipper extends CustomClipper<Rect> {
  _LeftClipper(this.dividerX);
  final double dividerX;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, 0, dividerX, size.height);

  @override
  bool shouldReclip(_LeftClipper oldClipper) => oldClipper.dividerX != dividerX;
}

class _RightClipper extends CustomClipper<Rect> {
  _RightClipper(this.dividerX);
  final double dividerX;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(dividerX, 0, size.width, size.height);

  @override
  bool shouldReclip(_RightClipper oldClipper) =>
      oldClipper.dividerX != dividerX;
}
