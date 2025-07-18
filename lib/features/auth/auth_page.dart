import 'package:flutter/cupertino.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Login'),
        border: null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShadCard(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        'Enter Verification Code',
                        style: ShadTheme.of(context).textTheme.h3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the 8-character code provided by your institution',
                        textAlign: TextAlign.center,
                        style: ShadTheme.of(context).textTheme.muted,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ShadInput(
                placeholder: const Text('H7K9M2X4'),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) {
                  print('Code: $value');
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ShadButton(
                  backgroundColor: ShadTheme.of(context).colorScheme.primary,
                  foregroundColor:
                      ShadTheme.of(context).colorScheme.primaryForeground,
                  child: const Text('Continue'),
                  onPressed: () {
                    context.go('/form');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
