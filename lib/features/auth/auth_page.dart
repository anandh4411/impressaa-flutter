import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/wave_background.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  String codeValue = '';

  void _handleLogin() async {
    if (codeValue.length < 8) return;

    setState(() => isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => isLoading = false);
      context.go('/form');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.colorScheme.primary,
      child: SafeArea(
        child: WaveBackground(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Top section with welcome text
                Expanded(
                  flex: 3,
                  child: Column(
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
                          color: theme.colorScheme.primaryForeground
                              .withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom section with form
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Verification Code',
                        style: theme.textTheme.h3,
                      ),
                      const SizedBox(height: 24),

                      // Normal Input
                      ShadInput(
                        placeholder: const Text('H7K9M2X4'),
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 8,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[A-Z0-9]')),
                        ],
                        onChanged: (value) {
                          setState(() => codeValue = value);
                        },
                      ),

                      const SizedBox(height: 32),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ShadButton(
                          onPressed: codeValue.length == 8 && !isLoading
                              ? _handleLogin
                              : null,
                          leading: isLoading
                              ? SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.primaryForeground,
                                  ),
                                )
                              : null,
                          child: Text(isLoading ? 'Verifying...' : 'Continue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
