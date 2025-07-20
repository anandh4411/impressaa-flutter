import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
        child: BlocConsumer<DynamicFormBloc, DynamicFormState>(
          listener: (context, state) {
            if (state is DynamicFormValidationError) {
              // Show validation errors
              _scrollToFirstError(state.errors);
            }
          },
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
              // Re-render form with validation errors
              return BlocBuilder<DynamicFormBloc, DynamicFormState>(
                buildWhen: (previous, current) => current is DynamicFormLoaded,
                builder: (context, loadedState) {
                  if (loadedState is DynamicFormLoaded) {
                    return _buildFormView(loadedState,
                        validationErrors: state.errors);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
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

  Widget _buildFormView(DynamicFormLoaded state,
      {Map<String, String>? validationErrors}) {
    return Column(
      children: [
        // Form Header (optional description)
        if (state.formConfig.description != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: ShadTheme.of(context).colorScheme.muted.withOpacity(0.5),
            child: Text(
              state.formConfig.description!,
              style: ShadTheme.of(context).textTheme.muted,
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
                        errorText: validationErrors?[field.id],
                      ),
                    ),
                  ),

                  // Spacing before buttons
                  const SizedBox(height: 32),

                  // Action Buttons (now part of scrollable content)
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

  void _handlePreview(DynamicFormLoaded state) {
    context.read<DynamicFormBloc>().add(DynamicFormPreviewRequested());

    // If validation passes, navigate to preview
    final errors = _validateFormData(state);
    if (errors.isEmpty) {
      // Navigate to preview page
      context.push('/form/preview', extra: {
        'formConfig': state.formConfig,
        'formData': state.formData,
      });
    }
  }

  void _handleSaveDraft(DynamicFormLoaded state) {
    // Save current form data as draft
    // This could be saved locally or sent to server
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saved successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Map<String, String> _validateFormData(DynamicFormLoaded state) {
    final errors = <String, String>{};

    for (final field in state.formConfig.fields) {
      final value = state.formData[field.id];

      if (field.required &&
          (value == null || value.toString().trim().isEmpty)) {
        errors[field.id] = '${field.label} is required';
      }
    }

    return errors;
  }

  void _scrollToFirstError(Map<String, String> errors) {
    if (errors.isNotEmpty) {
      // Scroll to top to show first error
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
