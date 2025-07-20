import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'data/form_models.dart';

class FormPreviewPage extends StatelessWidget {
  final FormConfigModel formConfig;
  final Map<String, dynamic> formData;

  const FormPreviewPage({
    super.key,
    required this.formConfig,
    required this.formData,
  });

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
          'Preview Form',
          style: TextStyle(
            color: theme.colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Preview Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form Title
                    Text(
                      formConfig.title,
                      style: theme.textTheme.h2,
                    ),
                    if (formConfig.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        formConfig.description!,
                        style: theme.textTheme.muted,
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Form Data Preview
                    ...formConfig.fields.map((field) {
                      final value = formData[field.id];
                      if (value == null || value.toString().trim().isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return _buildPreviewField(field, value);
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.background,
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
                      onPressed: () => _handleSubmit(context),
                      child: const Text('Submit Application'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton.outline(
                      onPressed: () => context.pop(),
                      child: const Text('Edit Form'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewField(FormFieldModel field, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }

  void _handleSubmit(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate API submission
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      Navigator.of(context).pop(); // Close loading dialog

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Success!'),
          content:
              const Text('Your application has been submitted successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                // Navigate back to auth page or home
                context.go('/');
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
