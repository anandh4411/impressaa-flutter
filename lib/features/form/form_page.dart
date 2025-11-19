import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../core/di/injection.dart';
import 'data/form_api_service.dart';
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
  File? _capturedPhoto;

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
                  // Photo Section
                  _buildPhotoSection(),
                  const SizedBox(height: 24),

                  // Form Fields
                  ...state.fields.map(
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

  Widget _buildPhotoSection() {
    final theme = ShadTheme.of(context);

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
                'ID Card Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.foreground,
                ),
              ),
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
          ),
          const SizedBox(height: 12),
          if (_capturedPhoto == null)
            GestureDetector(
              onTap: _openCamera,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted.withOpacity(0.3),
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
                            aspectRatio: 35 / 45, // Exact ratio used everywhere
                            child: Image.file(
                              _capturedPhoto!,
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
                                onTap: _openCamera,
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
                                    _capturedPhoto = null;
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

  Future<void> _openCamera() async {
    final result = await context.push<File>('/form/photo');
    if (result != null && mounted) {
      setState(() {
        _capturedPhoto = result;
      });
    }
  }

  void _handlePreview(DynamicFormLoaded state) {
    // Check if photo is captured first
    if (_capturedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture your ID photo before proceeding'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      // Scroll to top to show photo section
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
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
        'photo': _capturedPhoto,
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
