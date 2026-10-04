import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mobile_shared/mobile_shared.dart';

/// In-app camera screen for capturing user avatar.
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isInitializing = true;
  String? _errorMessage;
  XFile? _capturedFile;
  bool _isTakingPhoto = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCameraController(_selectedCameraIndex);
    }
  }

  Future<void> _initCameras() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;

      if (cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _errorMessage = AppLocalizations.of(context)!.cameraNoCameras;
        });
        return;
      }

      _cameras = cameras;
      // Default to front camera for selfie avatar if available
      int initialIndex = cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      if (initialIndex == -1) initialIndex = 0;

      _selectedCameraIndex = initialIndex;
      await _initCameraController(initialIndex);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = AppLocalizations.of(context)!.cameraPermissionDenied;
      });
    }
  }

  Future<void> _initCameraController(int cameraIndex) async {
    final camera = _cameras[cameraIndex];
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    _controller = controller;

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _errorMessage = AppLocalizations.of(context)!.cameraError;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isTakingPhoto) return;
    setState(() => _isInitializing = true);
    await _controller?.dispose();

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initCameraController(_selectedCameraIndex);
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    FlashMode nextMode;
    switch (_flashMode) {
      case FlashMode.off:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        nextMode = FlashMode.always;
        break;
      default:
        nextMode = FlashMode.off;
        break;
    }
    try {
      await _controller!.setFlashMode(nextMode);
      setState(() => _flashMode = nextMode);
    } catch (_) {}
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isTakingPhoto) return;

    try {
      setState(() => _isTakingPhoto = true);
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() {
        _capturedFile = file;
        _isTakingPhoto = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isTakingPhoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.cameraError)),
      );
    }
  }

  void _retakePhoto() {
    setState(() => _capturedFile = null);
  }

  void _usePhoto() {
    if (_capturedFile != null) {
      Navigator.pop(context, _capturedFile!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = CineplexColors.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview or captured photo or error
            Positioned.fill(
              child: _buildCameraBody(l10n, colors),
            ),

            // Top Bar: Back & Flash
            Positioned(
              top: 8,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                    icon: const Icon(Icons.close, color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  if (_capturedFile == null && _controller != null && _controller!.value.isInitialized)
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                      ),
                      icon: Icon(
                        _flashMode == FlashMode.off
                            ? Icons.flash_off
                            : (_flashMode == FlashMode.auto ? Icons.flash_auto : Icons.flash_on),
                        color: _flashMode == FlashMode.off ? Colors.white70 : colors.accent,
                        size: 26,
                      ),
                      onPressed: _toggleFlash,
                    ),
                ],
              ),
            ),

            // Bottom Bar: Controls
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: _buildBottomControls(l10n, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraBody(AppLocalizations l10n, CineplexColors colors) {
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(l10n.cameraInitializing, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, color: Colors.white38, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _initCameras,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_capturedFile != null) {
      return Center(
        child: Image.file(
          File(_capturedFile!.path),
          fit: BoxFit.contain,
        ),
      );
    }

    if (_controller != null && _controller!.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),

          // Circular Avatar Frame Overlay
          CustomPaint(
            painter: _AvatarFrameOverlayPainter(
              borderColor: colors.primary,
            ),
          ),

          // Instruction Text
          Positioned(
            top: 68,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.cameraCircleHint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBottomControls(AppLocalizations l10n, CineplexColors colors) {
    if (_errorMessage != null || _isInitializing) return const SizedBox.shrink();

    // If photo is already captured, show Retake and Use Photo buttons
    if (_capturedFile != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _retakePhoto,
                icon: const Icon(Icons.replay),
                label: Text(l10n.cameraRetake),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _usePhoto,
                icon: const Icon(Icons.check),
                label: Text(l10n.cameraUsePhoto),
              ),
            ),
          ],
        ),
      );
    }

    // Camera shooting controls
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Gallery or Placeholder
        const SizedBox(width: 48),

        // Shutter Button
        GestureDetector(
          onTap: _isTakingPhoto ? null : _takePhoto,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isTakingPhoto ? colors.primary.withValues(alpha: 0.5) : colors.primary,
              ),
              child: _isTakingPhoto
                  ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.camera_alt, color: Colors.white, size: 30),
            ),
          ),
        ),

        // Switch Camera Button
        if (_cameras.length > 1)
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              padding: const EdgeInsets.all(12),
            ),
            icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 28),
            onPressed: _switchCamera,
          )
        else
          const SizedBox(width: 48),
      ],
    );
  }
}

/// Custom painter that draws a dark translucent overlay with a transparent circular hole in the center.
class _AvatarFrameOverlayPainter extends CustomPainter {
  final Color borderColor;

  _AvatarFrameOverlayPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final radius = size.width * 0.36;

    // Dark overlay background
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final circlePath = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    final overlayPath = Path.combine(PathOperation.difference, backgroundPath, circlePath);

    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawPath(overlayPath, overlayPaint);

    // Circle border
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _AvatarFrameOverlayPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor;
  }
}
