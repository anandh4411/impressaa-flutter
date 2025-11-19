import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'form_preview_page.dart';
import 'data/form_models.dart';

class FormPreviewWrapper extends StatelessWidget {
  const FormPreviewWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;

    if (extra == null ||
        extra['formResponse'] == null ||
        extra['formData'] == null) {
      return _buildErrorPage(context);
    }

    return FormPreviewPage(
      formResponse: extra['formResponse'] as FormApiResponse,
      formData: extra['formData'] as Map<String, dynamic>,
      photo: extra['photo'] as dynamic,
    );
  }

  Widget _buildErrorPage(BuildContext context) {
    final theme = ShadTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.colorScheme.background,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.colorScheme.background,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.go('/form'),
          child: Icon(
            CupertinoIcons.back,
            color: theme.colorScheme.foreground,
          ),
        ),
        middle: Text(
          'Error',
          style: TextStyle(
            color: theme.colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: Center(
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
                  'No Form Data',
                  style: theme.textTheme.h3,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please go back and fill out the form first.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.p,
                ),
                const SizedBox(height: 24),
                ShadButton(
                  onPressed: () => context.go('/form'),
                  child: const Text('Back to Form'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
