import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../state/auth_bloc.dart';
import '../state/auth_event.dart';
import '../state/auth_state.dart';

class FormSection extends StatelessWidget {
  final VoidCallback? onSuccess;

  const FormSection({
    super.key,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          onSuccess?.call();
        } else if (state is AuthFailure) {
          // Show error toast
          ShadToaster.of(context).show(
            ShadToast.destructive(
              title: const Text('Login Failed'),
              description: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is! AuthInitial && state is! AuthLoading) {
          return const SizedBox.shrink();
        }

        final isLoading = state is AuthLoading;
        final currentState =
            state is AuthInitial ? state : AuthInitial();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Login method toggle
            ShadCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Method selection buttons
                    Row(
                      children: [
                        Expanded(
                          child: ShadButton.outline(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.read<AuthBloc>().add(
                                          AuthLoginMethodChanged(
                                              LoginMethod.institutionCode),
                                        );
                                  },
                            backgroundColor: currentState.currentMethod ==
                                    LoginMethod.institutionCode
                                ? ShadTheme.of(context).colorScheme.primary
                                : null,
                            child: const Text('Institution Code'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ShadButton.outline(
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.read<AuthBloc>().add(
                                          AuthLoginMethodChanged(
                                              LoginMethod.loginCode),
                                        );
                                  },
                            backgroundColor: currentState.currentMethod ==
                                    LoginMethod.loginCode
                                ? ShadTheme.of(context).colorScheme.primary
                                : null,
                            child: const Text('Login Code'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Conditional fields based on login method
                    if (currentState.currentMethod ==
                        LoginMethod.institutionCode) ...[
                      ShadInput(
                        placeholder: const Text('Institution Code'),
                        initialValue: currentState.institutionCode,
                        enabled: !isLoading,
                        onChanged: (value) {
                          context
                              .read<AuthBloc>()
                              .add(AuthInstitutionCodeChanged(value));
                        },
                      ),
                    ] else ...[
                      ShadInput(
                        placeholder: const Text('Login Code'),
                        initialValue: currentState.loginCode,
                        enabled: !isLoading,
                        onChanged: (value) {
                          context
                              .read<AuthBloc>()
                              .add(AuthLoginCodeChanged(value));
                        },
                      ),
                    ],
                    const SizedBox(height: 16),

                    // ID Number field (common for both methods)
                    ShadInput(
                      placeholder: const Text('ID Number'),
                      initialValue: currentState.idNumber,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        context.read<AuthBloc>().add(AuthIdNumberChanged(value));
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    ShadButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<AuthBloc>().add(AuthSubmitted());
                            },
                      child: isLoading
                          ? const CupertinoActivityIndicator()
                          : const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
