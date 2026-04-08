import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Handles adding watermark and sharing media files.
class ShareService {
  ShareService._();

  static const _defaultShareText = 'Senin kedin seni böyle görüyor! 🐱';

  /// Adds a "KediGözü" watermark to a PNG image [bytes] and returns the
  /// watermarked image bytes.
  static Future<Uint8List?> addWatermark(Uint8List imageBytes) async {
    try {
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final original = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(
        original.width.toDouble(),
        original.height.toDouble(),
      );

      // Draw original image
      canvas.drawImage(original, Offset.zero, Paint());

      // Draw watermark text
      final textStyle = ui.TextStyle(
        color: const Color(0x99FFFFFF),
        fontSize: size.width * 0.035,
        fontWeight: FontWeight.w600,
      );
      final paragraphBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(textAlign: TextAlign.left),
      )
        ..pushStyle(textStyle)
        ..addText('KediGözü 🐱');

      final paragraph = paragraphBuilder.build()
        ..layout(ui.ParagraphConstraints(width: size.width * 0.5));

      canvas.drawParagraph(
        paragraph,
        Offset(size.width * 0.03, size.height - paragraph.height - size.height * 0.03),
      );

      final picture = recorder.endRecording();
      final img = await picture.toImage(original.width, original.height);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

      original.dispose();
      img.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Watermark error: $e');
      return null;
    }
  }

  /// Shares the captured image with watermark applied.
  static Future<void> shareImage(Uint8List imageBytes) async {
    final watermarked = await addWatermark(imageBytes);
    final bytes = watermarked ?? imageBytes;

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/KediGozu_share_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: _defaultShareText,
      ),
    );
  }

  /// Shares a video file with watermark text (no image watermark for video).
  static Future<void> shareVideo(String videoPath) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(videoPath)],
        text: _defaultShareText,
      ),
    );
  }
}
