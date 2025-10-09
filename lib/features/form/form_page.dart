import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:impressaa/features/form/data/form_models.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'components/dynamic_form_field.dart';
import 'state/form_bloc.dart';
import 'state/form_event.dart';
import 'state/form_state.dart';

class FormPage extends StatelessWidget {
  final String? institutionId;

  const FormPage({
    super.key,
    this.institutionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DynamicFormBloc()
        ..add(DynamicFormLoadRequested(institutionId ?? 'inst_123')),
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
                state.formConfig.title,
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
              // Get the current loaded state from the bloc
              final bloc = context.read<DynamicFormBloc>();
              // For validation errors, we need to find the loaded state
              // This is a bit tricky, so let's handle it differently
              return _buildFormView(DynamicFormLoaded(
                formConfig: const FormConfigModel(
                  id: 'temp',
                  institutionId: 'temp',
                  title: 'Form',
                  fields: [],
                ),
                formData: {},
              ));
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
        if (state.formConfig.description != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.muted.withOpacity(0.5),
            child: Text(
              state.formConfig.description!,
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
                  ...state.formConfig.fields.map(
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

                  // Spacing before buttons
                  const SizedBox(height: 32),

                  // Action Buttons - Use simple buttons instead of BlocBuilder
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton(
                      onPressed: () => _handlePreview(state),
                      child: const Text('Preview Form'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton.outline(
                      onPressed: () => _handleSaveDraft(state),
                      child: const Text('Save as Draft'),
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _capturedPhoto!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _openCamera,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _capturedPhoto = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.xmark,
                            color: Colors.white,
                            size: 20,
                          ),
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
    if (result != null) {
      setState(() {
        _capturedPhoto = result;
      });
    }
  }

  void _handlePreview(DynamicFormLoaded state) {
    // Check if photo is captured
    if (_capturedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture your ID photo before proceeding'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (formKey.currentState!.saveAndValidate()) {
      // Get form data from form state
      final formData = formKey.currentState!.value;

      // Navigate to preview page
      context.push('/form/preview', extra: {
        'formConfig': state.formConfig,
        'formData': formData,
        'photo': _capturedPhoto,
      });
    } else {
      // Validation failed, scroll to top to show errors
      _scrollToFirstError();
    }
  }

  void _handleSaveDraft(DynamicFormLoaded state) {
    // Save current form data as draft (even if invalid)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
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
