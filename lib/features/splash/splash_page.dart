import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Simulate app initialization (loading configs, checking auth, etc.)
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to auth page when ready
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.colorScheme.background,
      child: SafeArea(
        child: Column(
          children: [
            // Main content area - Logo in center
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Bottom branding
            Padding(
              padding: const EdgeInsets.only(bottom: 48.0),
              child: Text(
                'Impressaa',
                style: theme.textTheme.h4?.copyWith(
                  color: theme.colorScheme.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
