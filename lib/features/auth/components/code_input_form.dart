import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../state/auth_bloc.dart';
import '../state/auth_event.dart';
import '../state/auth_state.dart';

class CodeInputForm extends StatefulWidget {
  final VoidCallback? onSuccess;

  const CodeInputForm({
    super.key,
    this.onSuccess,
  });

  @override
  State<CodeInputForm> createState() => _CodeInputFormState();
}

class _CodeInputFormState extends State<CodeInputForm> {
  final formKey = GlobalKey<ShadFormState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          widget.onSuccess?.call();
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: ShadForm(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShadInputFormField(
              id: 'verification_code',
              label: const Text('Verification Code'),
              placeholder: const Text('H7K9M2X4'),
              description: const Text(
                  'Enter the 8-character code provided by your institution'),
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              maxLength: 8,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                UpperCaseTextFormatter(),
              ],
              onChanged: (value) {
                context.read<AuthBloc>().add(AuthCodeChanged(value));
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Verification code is required';
                }
                if (value.length < 8) {
                  return 'Code must be 8 characters';
                }
                if (!RegExp(r'^[A-Z0-9]{8}$').hasMatch(value)) {
                  return 'Code must contain only letters and numbers';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return ShadButton(
                  onPressed: isLoading ? null : _handleSubmit,
                  leading: isLoading
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  child: Text(isLoading ? 'Verifying...' : 'Continue'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (formKey.currentState!.saveAndValidate()) {
      final code = formKey.currentState!.value['verification_code'] as String;
      context.read<AuthBloc>().add(AuthCodeChanged(code));
      context.read<AuthBloc>().add(AuthSubmitted());
    }
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
