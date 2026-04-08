import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kedigoz/features/camera/widgets/intensity_slider.dart';
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

      // Prefer back camera
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
      enableAudio: false,
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
    if (_cameras.length < 2) return;
    setState(() => _isInitializing = true);
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _initCamera(_cameras[_currentCameraIndex]);
  }

  void _toggleVisionMode() {
    setState(() => _isCatVision = !_isCatVision);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview with filter
          _buildCameraPreview(),

          // Top bar: camera switch button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _buildCameraSwitchButton(),
          ),

          // Bottom controls
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

    return CatVisionFilter(
      intensity: _filterIntensity,
      enabled: _isCatVision,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller.value.previewSize!.height,
            height: controller.value.previewSize!.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraSwitchButton() {
    if (_cameras.length < 2) return const SizedBox.shrink();

    return IconButton(
      onPressed: _isInitializing ? null : _switchCamera,
      icon: const Icon(Icons.flip_camera_android),
      color: Colors.white,
      iconSize: 30,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildBottomControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Intensity slider
            IntensitySlider(
              value: _filterIntensity,
              onChanged: (v) => setState(() => _filterIntensity = v),
              visible: _isCatVision,
            ),
            const SizedBox(height: 16),
            // Vision mode toggle
            VisionModeToggle(
              isCatVision: _isCatVision,
              onToggle: _toggleVisionMode,
            ),
          ],
        ),
      ),
    );
  }
}
