import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'code_input_form.dart';

class FormSection extends StatelessWidget {
  final VoidCallback? onSuccess;

  const FormSection({
    super.key,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Verification Code',
          style: theme.textTheme.h3,
        ),
        const SizedBox(height: 24),
        CodeInputForm(onSuccess: onSuccess),
      ],
    );
  }
}
