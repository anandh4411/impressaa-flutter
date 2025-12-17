import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../shared/utils/toast_helper.dart';
import '../state/auth_bloc.dart';
import '../state/auth_event.dart';
import '../state/auth_state.dart';

class FormSection extends StatefulWidget {
  final VoidCallback? onSuccess;

  const FormSection({
    super.key,
    this.onSuccess,
  });

  @override
  State<FormSection> createState() => _FormSectionState();
}

class _FormSectionState extends State<FormSection> {
  void _validateAndSubmit(BuildContext context, AuthInitial state) {
    // Validate based on login method
    if (state.currentMethod == LoginMethod.institutionCode) {
      if (state.institutionCode.trim().isEmpty) {
        ToastHelper.showError(
          context,
          title: 'Validation Error',
          description: 'Please enter institution code',
        );
        return;
      }
      if (state.idNumber.trim().isEmpty) {
        ToastHelper.showError(
          context,
          title: 'Validation Error',
          description: 'Please enter ID number',
        );
        return;
      }
    } else {
      if (state.loginCode.trim().isEmpty) {
        ToastHelper.showError(
          context,
          title: 'Validation Error',
          description: 'Please enter login code',
        );
        return;
      }
    }

    // All fields valid, submit
    context.read<AuthBloc>().add(AuthSubmitted());
  }

  bool _isFormValid(AuthInitial state) {
    if (state.currentMethod == LoginMethod.institutionCode) {
      return state.institutionCode.trim().isNotEmpty &&
             state.idNumber.trim().isNotEmpty;
    } else {
      return state.loginCode.trim().isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          widget.onSuccess?.call();
        } else if (state is AuthFailure) {
          // Show error toast at top
          ToastHelper.showError(
            context,
            title: 'Login Failed',
            description: state.message,
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

        return ShadCard(
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
                                              LoginMethod.loginCode),
                                        );
                                  },
                            backgroundColor: currentState.currentMethod ==
                                    LoginMethod.loginCode
                                ? ShadTheme.of(context).colorScheme.primary
                                : null,
                            foregroundColor: currentState.currentMethod ==
                                    LoginMethod.loginCode
                                ? ShadTheme.of(context).colorScheme.primaryForeground
                                : null,
                            child: const Text(
                              'Login Code',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
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
                                              LoginMethod.institutionCode),
                                        );
                                  },
                            backgroundColor: currentState.currentMethod ==
                                    LoginMethod.institutionCode
                                ? ShadTheme.of(context).colorScheme.primary
                                : null,
                            foregroundColor: currentState.currentMethod ==
                                    LoginMethod.institutionCode
                                ? ShadTheme.of(context).colorScheme.primaryForeground
                                : null,
                            child: const Text(
                              'Institution\nCode',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, height: 1.2),
                            ),
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
                      const SizedBox(height: 16),
                      // ID Number field (only for institution code login)
                      ShadInput(
                        placeholder: const Text('ID Number'),
                        initialValue: currentState.idNumber,
                        enabled: !isLoading,
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          context.read<AuthBloc>().add(AuthIdNumberChanged(value));
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
                    const SizedBox(height: 24),

                    // Submit button - disabled when form is invalid or loading
                    ShadButton(
                      onPressed: (isLoading || !_isFormValid(currentState))
                          ? null
                          : () => _validateAndSubmit(context, currentState),
                      child: isLoading
                          ? const CupertinoActivityIndicator()
                          : const Text('Login'),
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }
}
