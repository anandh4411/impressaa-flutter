import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:image/image.dart' as img;

class PhotoCapturePage extends StatefulWidget {
  final String? formId;
  final String? aspectRatio; // e.g., "35:45"

  const PhotoCapturePage({
    super.key,
    this.formId,
    this.aspectRatio,
  });

  @override
  State<PhotoCapturePage> createState() => _PhotoCapturePageState();
}

class _PhotoCapturePageState extends State<PhotoCapturePage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  String? _errorMessage;
  File? _capturedImage;
  bool _hasShownGuidelines = false; // Track if modal was shown

  // Photo aspect ratio (parsed from widget.aspectRatio or default)
  late final double _photoAspectRatio;

  @override
  void initState() {
    super.initState();
    _parseAspectRatio();
    _initializeCamera();
  }

  void _parseAspectRatio() {
    // Parse aspect ratio from widget (e.g., "35:45" -> 35/45)
    if (widget.aspectRatio != null) {
      final parts = widget.aspectRatio!.split(':');
      if (parts.length == 2) {
        final width = double.tryParse(parts[0]);
        final height = double.tryParse(parts[1]);
        if (width != null && height != null && height != 0) {
          _photoAspectRatio = width / height;
          return;
        }
      }
    }
    // Default to 35:45 ratio
    _photoAspectRatio = 35 / 45;
  }

  String _formatAspectRatio(String ratio) {
    // Convert "35:45" to "35mm × 45mm"
    final parts = ratio.split(':');
    if (parts.length == 2) {
      return '${parts[0]}mm × ${parts[1]}mm';
    }
    return ratio;
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();

      // Find back camera only
      final backCamera = _cameras?.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      if (backCamera == null) {
        setState(() {
          _errorMessage = 'No camera found on this device';
          _isInitializing = false;
        });
        return;
      }

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });

        // Show guidelines modal after camera is ready
        if (!_hasShownGuidelines) {
          _hasShownGuidelines = true;
          // Small delay to let the UI settle
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _showGuidelinesModal();
            }
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
        _isInitializing = false;
      });
    }
  }

  void _showGuidelinesModal() {
    final theme = ShadTheme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false, // User must click OK
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              CupertinoIcons.info_circle,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Photo Guidelines',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.foreground,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please follow these guidelines for a perfect ID photo:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.foreground,
                ),
              ),
              const SizedBox(height: 16),
              _buildModalInstructionItem(
                'Center your face within the circle outline',
                CupertinoIcons.scope,
              ),
              const SizedBox(height: 12),
              _buildModalInstructionItem(
                'Keep good lighting in front of you',
                CupertinoIcons.light_max,
              ),
              const SizedBox(height: 12),
              _buildModalInstructionItem(
                'Use a plain background if possible',
                CupertinoIcons.rectangle_fill_on_rectangle_fill,
              ),
              const SizedBox(height: 12),
              _buildModalInstructionItem(
                'Position your face within the frame',
                CupertinoIcons.person_crop_square,
              ),
              const SizedBox(height: 12),
              _buildModalInstructionItem(
                'Look directly at the camera',
                CupertinoIcons.eye,
              ),
              const SizedBox(height: 12),
              _buildModalInstructionItem(
                'Wear the official uniform',
                CupertinoIcons.person_2,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.photo,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatAspectRatio(widget.aspectRatio ?? "35:45"),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ShadButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it, Let\'s Start'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalInstructionItem(String text, IconData icon) {
    final theme = ShadTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.mutedForeground,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.foreground,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      // Capture the photo
      final image = await _controller!.takePicture();

      // Crop to correct aspect ratio
      final croppedImage = await _cropToAspectRatio(image.path);

      setState(() {
        _capturedImage = croppedImage;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing photo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<File> _cropToAspectRatio(String imagePath) async {
    // Read the image
    final bytes = await File(imagePath).readAsBytes();
    var originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      return File(imagePath); // Return original if decode fails
    }

    // Apply EXIF orientation to get correct dimensions
    // Phone cameras often save landscape with rotation metadata
    originalImage = img.bakeOrientation(originalImage);

    // Calculate crop dimensions for target aspect ratio (width:height)
    // For 35:45, target is 0.778 (narrower than tall - portrait)
    final targetAspectRatio = _photoAspectRatio;
    final currentAspectRatio = originalImage.width / originalImage.height;

    int cropWidth;
    int cropHeight;
    int offsetX = 0;
    int offsetY = 0;

    if (currentAspectRatio > targetAspectRatio) {
      // Image is too wide relative to target, crop the width
      // Keep full height, reduce width to match target ratio
      cropHeight = originalImage.height;
      cropWidth = (cropHeight * targetAspectRatio).round();
      offsetX = ((originalImage.width - cropWidth) / 2).round();
    } else {
      // Image is too tall relative to target, crop the height
      // Keep full width, reduce height to match target ratio
      cropWidth = originalImage.width;
      cropHeight = (cropWidth / targetAspectRatio).round();
      // Center crop to match the on-screen guide that users align to
      offsetY = ((originalImage.height - cropHeight) / 2).round();
    }

    // Crop the image
    final croppedImage = img.copyCrop(
      originalImage,
      x: offsetX,
      y: offsetY,
      width: cropWidth,
      height: cropHeight,
    );

    // Save the cropped image
    final croppedPath = imagePath.replaceAll('.jpg', '_cropped.jpg');
    final croppedFile = File(croppedPath);
    await croppedFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 95));

    // Delete original uncropped image
    await File(imagePath).delete();

    return croppedFile;
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  void _confirmPhoto() {
    if (_capturedImage != null) {
      // Navigate back with the captured image
      context.pop(_capturedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.colorScheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.colorScheme.background,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.pop(),
          child: Icon(
            CupertinoIcons.back,
            color: theme.colorScheme.foreground,
          ),
        ),
        middle: Text(
          'ID Card Photo',
          style: TextStyle(
            color: theme.colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showGuidelinesModal,
          child: Icon(
            CupertinoIcons.info_circle,
            color: theme.colorScheme.foreground,
          ),
        ),
      ),
      child: SafeArea(
        child:
            _capturedImage != null ? _buildPreviewView() : _buildCameraView(),
      ),
    );
  }

  Widget _buildCameraView() {
    final theme = ShadTheme.of(context);

    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Camera Error',
                style: theme.textTheme.h3,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.p,
              ),
            ],
          ),
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: Text('Camera not available'),
      );
    }

    return Column(
      children: [
        // Camera Preview Section - Full screen
        Expanded(
          child: Container(
            color: Colors.black,
            width: double.infinity,
            child: Stack(
              children: [
                // Camera preview - full width, proper aspect
                SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.previewSize!.height,
                      height: _controller!.value.previewSize!.width,
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),

                // Face outline guide overlay
                Center(
                  child: Image.asset(
                    'assets/images/outline.png',
                    width: MediaQuery.of(context).size.width * 0.85,
                    fit: BoxFit.contain,
                  ),
                ),

                // Size requirement badge at top
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.photo,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatAspectRatio(widget.aspectRatio ?? "35:45"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Capture Button Bar at Bottom
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Center(
            child: GestureDetector(
              onTap: _capturePhoto,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 4,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewView() {
    final theme = ShadTheme.of(context);

    return Column(
      children: [
        // Image Preview
        Expanded(
          child: Center(
            child: Image.file(
              _capturedImage!,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // Action Buttons
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.card,
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.border,
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ShadButton(
                  onPressed: _confirmPhoto,
                  child: const Text('Use This Photo'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ShadButton.outline(
                  onPressed: _retakePhoto,
                  child: const Text('Retake Photo'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
