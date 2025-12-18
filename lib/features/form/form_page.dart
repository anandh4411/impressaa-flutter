import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:image/image.dart' as img;
import '../../core/di/injection.dart';
import 'data/form_api_service.dart';
import 'data/form_models.dart';
import '../../core/storage/auth_storage.dart';
import 'components/dynamic_form_field.dart';
import 'state/form_bloc.dart';
import 'state/form_event.dart';
import 'state/form_state.dart';

class FormPage extends StatelessWidget {
  const FormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DynamicFormBloc(
        formApiService: getIt<FormApiService>(),
        authStorage: getIt<AuthStorage>(),
      )..add(DynamicFormLoadRequested()),
      child: const _FormPageView(),
    );
  }
}

class _FormPageView extends StatefulWidget {
  const _FormPageView();

  @override
  State<_FormPageView> createState() => _FormPageViewState();
}

class _FormPageViewState extends State<_FormPageView> {
  final formKey = GlobalKey<ShadFormState>();
  final scrollController = ScrollController();
  final Map<dynamic, File> _capturedPhotos = {}; // Map field ID to captured photo

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
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
        middle: BlocBuilder<DynamicFormBloc, DynamicFormState>(
          builder: (context, state) {
            if (state is DynamicFormLoaded) {
              return Text(
                state.formConfig?.name ?? 'Form',
                style: TextStyle(
                  color: theme.colorScheme.foreground,
                  fontWeight: FontWeight.w600,
                ),
              );
            }
            return const Text('Form');
          },
        ),
      ),
      child: SafeArea(
        child: BlocBuilder<DynamicFormBloc, DynamicFormState>(
          builder: (context, state) {
            if (state is DynamicFormLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DynamicFormError) {
              return _buildErrorView(state.message);
            }

            if (state is DynamicFormLoaded) {
              return _buildFormView(state);
            }

            if (state is DynamicFormValidationError) {
              // Show validation errors - this state doesn't persist form data
              // so we should handle this better in the UI
              return Center(
                child: Text('Validation errors occurred'),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
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
              'Error',
              style: ShadTheme.of(context).textTheme.h3,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ShadTheme.of(context).textTheme.p,
            ),
            const SizedBox(height: 24),
            ShadButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView(DynamicFormLoaded state) {
    final theme = ShadTheme.of(context);

    return Column(
      children: [
        // Form Header (optional description)
        if (state.formConfig?.description != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.muted.withOpacity(0.5),
            child: Text(
              state.formConfig!.description!,
              style: theme.textTheme.muted,
              textAlign: TextAlign.center,
            ),
          ),

        // Scrollable Form Content (including buttons)
        Expanded(
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: ShadForm(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Camera/Photo Sections (for file type fields)
                  ...state.fields
                      .where((field) => field.type == FormFieldType.file)
                      .map((field) => Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _buildPhotoSection(field),
                          )),

                  // Form Fields (exclude file type as they're handled above)
                  ...state.fields
                      .where((field) => field.type != FormFieldType.file)
                      .map(
                        (field) => Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: DynamicFormField(
                            field: field,
                            value: state.formData[field.id],
                            onChanged: (value) {
                              context.read<DynamicFormBloc>().add(
                                    DynamicFormFieldChanged(
                                        fieldId: field.id, value: value),
                                  );
                            },
                          ),
                        ),
                      ),

                  // Spacing before button
                  const SizedBox(height: 32),

                  // Preview Button
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton(
                      onPressed: () => _handlePreview(state),
                      child: const Text('Preview Form'),
                    ),
                  ),

                  // Extra bottom padding for safe area
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(FormFieldModel field) {
    final theme = ShadTheme.of(context);
    final capturedPhoto = _capturedPhotos[field.id];

    // Parse aspect ratio from field (e.g., "35:45" -> 35/45)
    double aspectRatio = 35 / 45; // Default
    if (field.aspectRatio != null) {
      final parts = field.aspectRatio!.split(':');
      if (parts.length == 2) {
        final width = double.tryParse(parts[0]);
        final height = double.tryParse(parts[1]);
        if (width != null && height != null && height != 0) {
          aspectRatio = width / height;
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.border,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.camera,
                size: 20,
                color: theme.colorScheme.foreground,
              ),
              const SizedBox(width: 8),
              Text(
                field.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground,
                ),
              ),
              if (field.required) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Required',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          if (capturedPhoto == null)
            // Show camera only or camera + gallery based on accessGallery flag
            field.accessGallery
                ? _buildCameraGalleryOptions(field, theme)
                : GestureDetector(
                    onTap: () => _openCamera(field),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.muted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.border,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.camera_fill,
                            size: 48,
                            color: theme.colorScheme.mutedForeground,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to capture photo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Use back camera for best results',
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
          else
            Column(
              children: [
                // Show photo in exact aspect ratio
                Center(
                  child: Container(
                    width: 160, // Fixed width for consistency
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.border,
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: AspectRatio(
                            aspectRatio: aspectRatio,
                            child: Image.file(
                              capturedPhoto,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Action buttons overlay
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Retake button
                              GestureDetector(
                                onTap: () => _openCamera(field),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.refresh,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Remove button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _capturedPhotos.remove(field.id);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.xmark,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Dimension badge below photo
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '35mm × 45mm',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCameraGalleryOptions(FormFieldModel field, ShadThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Choose an option',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.foreground,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Camera option
              Expanded(
                child: GestureDetector(
                  onTap: () => _openCamera(field),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.camera_fill,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Camera',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Gallery option
              Expanded(
                child: GestureDetector(
                  onTap: () => _openGallery(field),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.photo_fill,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gallery',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openCamera(FormFieldModel field) async {
    // Pass aspect ratio to photo capture page
    final result = await context.push<File>(
      '/form/photo',
      extra: field.aspectRatio,
    );
    if (result != null && mounted) {
      setState(() {
        _capturedPhotos[field.id] = result;
      });
    }
  }

  Future<void> _openGallery(FormFieldModel field) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null || !mounted) return;

    // Crop the selected image to aspect ratio
    final croppedFile = await _cropImageToAspectRatio(
      pickedFile.path,
      field.aspectRatio,
    );

    if (croppedFile != null && mounted) {
      setState(() {
        _capturedPhotos[field.id] = croppedFile;
      });
    }
  }

  Future<File?> _cropImageToAspectRatio(String imagePath, String? aspectRatioStr) async {
    try {
      // Parse aspect ratio
      double targetAspectRatio = 35 / 45; // Default
      if (aspectRatioStr != null) {
        final parts = aspectRatioStr.split(':');
        if (parts.length == 2) {
          final width = double.tryParse(parts[0]);
          final height = double.tryParse(parts[1]);
          if (width != null && height != null && height != 0) {
            targetAspectRatio = width / height;
          }
        }
      }

      // Read the image
      final bytes = await File(imagePath).readAsBytes();
      var originalImage = img.decodeImage(bytes);

      if (originalImage == null) return File(imagePath);

      // Apply EXIF orientation
      originalImage = img.bakeOrientation(originalImage);

      // Calculate crop dimensions
      final currentAspectRatio = originalImage.width / originalImage.height;

      int cropWidth;
      int cropHeight;
      int offsetX = 0;
      int offsetY = 0;

      if (currentAspectRatio > targetAspectRatio) {
        // Image is too wide, crop the width
        cropHeight = originalImage.height;
        cropWidth = (cropHeight * targetAspectRatio).round();
        offsetX = ((originalImage.width - cropWidth) / 2).round();
      } else {
        // Image is too tall, crop the height
        cropWidth = originalImage.width;
        cropHeight = (cropWidth / targetAspectRatio).round();
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
      final croppedPath = imagePath.replaceAll(
        RegExp(r'\.(jpg|jpeg|png)$', caseSensitive: false),
        '_cropped.jpg',
      );
      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(img.encodeJpg(croppedImage, quality: 95));

      return croppedFile;
    } catch (e) {
      // Return original file if cropping fails
      return File(imagePath);
    }
  }

  void _handlePreview(DynamicFormLoaded state) {
    // Get all file type fields
    final fileFields = state.fields.where((f) => f.type == FormFieldType.file);

    // Check if all required photos are captured
    for (final field in fileFields) {
      if (field.required && !_capturedPhotos.containsKey(field.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please capture ${field.label} before proceeding'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        // Scroll to top to show photo sections
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      }
    }

    // Validate the form
    final isValid = formKey.currentState?.saveAndValidate() ?? false;

    if (!isValid) {
      // Validation failed, scroll to top to show errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      _scrollToFirstError();
      return;
    }

    // Get form data from form state
    final formData = formKey.currentState?.value ?? {};

    // Navigate to preview page
    try {
      context.push('/form/preview', extra: {
        'formResponse': state.formResponse,
        'formData': formData,
        'photos': _capturedPhotos, // Pass all captured photos
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Navigation error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToFirstError() {
    // Scroll to top to show first error
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
