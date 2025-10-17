import 'package:flutter/cupertino.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HelpSection extends StatelessWidget {
  const HelpSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.card.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.info_circle,
                size: 16,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(width: 6),
              Text(
                'New to this app?',
                style: theme.textTheme.muted?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Contact our customer care for verification code',
            style: theme.textTheme.muted?.copyWith(
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '📞 +91 98765 43210',
            style: theme.textTheme.p?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
