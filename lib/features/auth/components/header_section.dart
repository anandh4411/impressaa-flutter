import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome',
          style: theme.textTheme.h1?.copyWith(
            color: theme.colorScheme.primaryForeground,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your verification code to access the ID card form',
          style: theme.textTheme.p?.copyWith(
            color: theme.colorScheme.primaryForeground.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
