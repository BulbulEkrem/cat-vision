import 'package:flutter/material.dart';

/// Toggle button to switch between cat and human vision modes.
class VisionModeToggle extends StatelessWidget {
  const VisionModeToggle({
    super.key,
    required this.isCatVision,
    required this.onToggle,
  });

  final bool isCatVision;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isCatVision
              ? const Color(0xFF7CFC00).withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: isCatVision
                  ? const Color(0xFF7CFC00).withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.2),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCatVision ? Icons.pets : Icons.person,
              color: isCatVision ? Colors.black : Colors.black87,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isCatVision ? 'Kedi Görüşü' : 'İnsan Görüşü',
              style: TextStyle(
                color: isCatVision ? Colors.black : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
