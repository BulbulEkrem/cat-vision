import 'package:flutter/material.dart';

/// A shutter button that supports tap (photo) and long-press (video).
class CaptureButton extends StatefulWidget {
  const CaptureButton({
    super.key,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.isRecording,
  });

  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;
  final bool isRecording;

  @override
  State<CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends State<CaptureButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.isRecording) {
          _animController.forward().then((_) => _animController.reverse());
          widget.onTap();
        }
      },
      onLongPressStart: (_) {
        _animController.forward();
        widget.onLongPressStart();
      },
      onLongPressEnd: (_) {
        _animController.reverse();
        widget.onLongPressEnd();
      },
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          );
        },
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.isRecording ? 30 : 62,
              height: widget.isRecording ? 30 : 62,
              decoration: BoxDecoration(
                color: widget.isRecording ? Colors.red : Colors.white,
                borderRadius: BorderRadius.circular(
                  widget.isRecording ? 8 : 31,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
