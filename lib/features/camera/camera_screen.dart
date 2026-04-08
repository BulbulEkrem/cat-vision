import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kedigoz/features/camera/services/capture_service.dart';
import 'package:kedigoz/features/camera/services/share_service.dart';
import 'package:kedigoz/features/camera/widgets/capture_button.dart';
import 'package:kedigoz/features/camera/widgets/comparison_view.dart';
import 'package:kedigoz/features/camera/widgets/info_panel.dart';
import 'package:kedigoz/features/camera/widgets/intensity_slider.dart';
import 'package:kedigoz/features/camera/widgets/recording_timer.dart';
import 'package:kedigoz/features/camera/widgets/vision_mode_toggle.dart';
import 'package:kedigoz/features/filters/cat_vision_filter.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;

  bool _isCatVision = true;
  double _filterIntensity = 0.75;
  bool _isInitializing = true;
  String? _errorMessage;

  bool _isRecording = false;
  bool _isComparisonMode = false;
  Uint8List? _lastCapturedImage;

  final _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(_cameras[_currentCameraIndex]);
    }
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Kamera bulunamadı';
        });
        return;
      }

      _currentCameraIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (_currentCameraIndex < 0) _currentCameraIndex = 0;

      await _initCamera(_cameras[_currentCameraIndex]);
    } on CameraException catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Kamera hatası: ${e.description}';
      });
    }
  }

  Future<void> _initCamera(CameraDescription camera) async {
    final previousController = _controller;
    _controller = null;
    await previousController?.dispose();

    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isInitializing = false;
        _errorMessage = null;
      });
    } on CameraException catch (e) {
      await controller.dispose();
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Kamera başlatılamadı: ${e.description}';
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isRecording) return;
    setState(() => _isInitializing = true);
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _initCamera(_cameras[_currentCameraIndex]);
  }

  void _toggleVisionMode() {
    setState(() {
      _isCatVision = !_isCatVision;
      _isComparisonMode = false;
    });
  }

  void _toggleComparisonMode() {
    setState(() {
      _isComparisonMode = !_isComparisonMode;
      if (_isComparisonMode) _isCatVision = true;
    });
  }

  // ── Photo Capture ──

  Future<void> _capturePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    // Flash animation
    setState(() {});
    HapticFeedback.mediumImpact();

    final path = await CaptureService.capturePhoto(_repaintBoundaryKey);

    // Also capture the bytes for potential sharing
    final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary != null) {
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        _lastCapturedImage = byteData.buffer.asUint8List();
      }
    }

    if (!mounted) return;

    if (path != null) {
      _showCaptureSnackBar('Fotoğraf kaydedildi!', showShare: true);
    } else {
      _showCaptureSnackBar('Fotoğraf kaydedilemedi', isError: true);
    }
  }

  // ── Video Recording ──

  Future<void> _startRecording() async {
    final controller = _controller;
    if (controller == null || _isRecording) return;

    await CaptureService.startVideoRecording(controller);
    HapticFeedback.heavyImpact();
    setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    final controller = _controller;
    if (controller == null || !_isRecording) return;

    setState(() => _isRecording = false);
    final path = await CaptureService.stopVideoRecording(controller);

    if (!mounted) return;

    if (path != null) {
      _showVideoSavedSnackBar(path);
    } else {
      _showCaptureSnackBar('Video kaydedilemedi', isError: true);
    }
  }

  // ── Sharing ──

  Future<void> _shareLastPhoto() async {
    final bytes = _lastCapturedImage;
    if (bytes == null) return;
    await ShareService.shareImage(bytes);
  }

  // ── Snackbars ──

  void _showCaptureSnackBar(
    String message, {
    bool isError = false,
    bool showShare = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        action: showShare && _lastCapturedImage != null
            ? SnackBarAction(
                label: 'Paylaş',
                textColor: Colors.white,
                onPressed: _shareLastPhoto,
              )
            : null,
      ),
    );
  }

  void _showVideoSavedSnackBar(String path) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Video kaydedildi!'),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Paylaş',
          textColor: Colors.white,
          onPressed: () => ShareService.shareVideo(path),
        ),
      ),
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview with filter
          RepaintBoundary(
            key: _repaintBoundaryKey,
            child: _buildCameraPreview(),
          ),

          // Flash overlay on capture
          // (handled by the RepaintBoundary capture)

          // Recording timer (top center)
          if (_isRecording)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: 0,
              right: 0,
              child: const Center(child: RecordingTimer()),
            ),

          // Top bar buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: Column(
              children: [
                _buildIconButton(
                  icon: Icons.flip_camera_android,
                  onPressed: _cameras.length >= 2 && !_isRecording
                      ? _switchCamera
                      : null,
                ),
                const SizedBox(height: 8),
                _buildIconButton(
                  icon: Icons.compare,
                  onPressed: _isRecording ? null : _toggleComparisonMode,
                  isActive: _isComparisonMode,
                ),
                const SizedBox(height: 8),
                _buildIconButton(
                  icon: Icons.info_outline,
                  onPressed: () => InfoPanel.show(context),
                ),
              ],
            ),
          ),

          // Bottom controls
          if (!_isRecording || _isRecording)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomControls(),
            ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7CFC00)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final cameraPreview = SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    );

    if (_isComparisonMode) {
      return ComparisonView(
        filterIntensity: _filterIntensity,
        child: cameraPreview,
      );
    }

    return CatVisionFilter(
      intensity: _filterIntensity,
      enabled: _isCatVision,
      child: cameraPreview,
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isActive = false,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: isActive ? const Color(0xFF7CFC00) : Colors.white,
      iconSize: 28,
      style: IconButton.styleFrom(
        backgroundColor: isActive
            ? const Color(0xFF7CFC00).withValues(alpha: 0.2)
            : Colors.black.withValues(alpha: 0.4),
        padding: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _buildBottomControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Intensity slider
            if (!_isComparisonMode)
              IntensitySlider(
                value: _filterIntensity,
                onChanged: (v) => setState(() => _filterIntensity = v),
                visible: _isCatVision,
              ),
            const SizedBox(height: 12),

            // Capture button + toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Share last photo button
                  _lastCapturedImage != null && !_isRecording
                      ? IconButton(
                          onPressed: _shareLastPhoto,
                          icon: const Icon(Icons.share),
                          color: Colors.white,
                          iconSize: 28,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.black.withValues(alpha: 0.4),
                            padding: const EdgeInsets.all(12),
                          ),
                        )
                      : const SizedBox(width: 52),

                  // Capture button (tap = photo, long press = video)
                  CaptureButton(
                    onTap: _capturePhoto,
                    onLongPressStart: _startRecording,
                    onLongPressEnd: _stopRecording,
                    isRecording: _isRecording,
                  ),

                  // Vision mode toggle (compact) or spacer during recording
                  _isRecording
                      ? const SizedBox(width: 52)
                      : const SizedBox(width: 52),
                ],
              ),
            ),

            if (!_isRecording && !_isComparisonMode) ...[
              const SizedBox(height: 12),
              VisionModeToggle(
                isCatVision: _isCatVision,
                onToggle: _toggleVisionMode,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
