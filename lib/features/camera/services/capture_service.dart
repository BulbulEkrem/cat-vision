import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

/// Handles capturing photos/videos with filters applied and saving to gallery.
class CaptureService {
  CaptureService._();

  /// Captures the widget rendered inside the given [boundaryKey] as a PNG,
  /// saves it to gallery, and returns the file path.
  static Future<String?> capturePhoto(GlobalKey boundaryKey) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();

      // Save to gallery
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(pngBytes),
        quality: 95,
        name: 'KediGozu_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        return result['filePath'] as String?;
      }

      // Fallback: save to temp directory
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/KediGozu_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);
      return file.path;
    } catch (e) {
      debugPrint('Photo capture error: $e');
      return null;
    }
  }

  /// Starts video recording on the given [controller].
  static Future<void> startVideoRecording(
    CameraController controller,
  ) async {
    if (controller.value.isRecordingVideo) return;
    await controller.startVideoRecording();
  }

  /// Stops video recording, saves the file to gallery, and returns the path.
  static Future<String?> stopVideoRecording(
    CameraController controller,
  ) async {
    if (!controller.value.isRecordingVideo) return null;

    try {
      final xFile = await controller.stopVideoRecording();

      // Save to gallery
      final result = await ImageGallerySaver.saveFile(xFile.path);
      if (result['isSuccess'] == true) {
        return result['filePath'] as String? ?? xFile.path;
      }

      return xFile.path;
    } catch (e) {
      debugPrint('Video recording error: $e');
      return null;
    }
  }
}
