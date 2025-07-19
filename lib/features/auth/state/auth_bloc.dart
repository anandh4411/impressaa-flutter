import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCodeChanged>(_onCodeChanged);
    on<AuthSubmitted>(_onSubmitted);
    on<AuthReset>(_onReset);
  }

  String _currentCode = '';

  void _onCodeChanged(AuthCodeChanged event, Emitter<AuthState> emit) {
    _currentCode = event.code.toUpperCase();
  }

  Future<void> _onSubmitted(
      AuthSubmitted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock validation - replace with actual API call
      if (_currentCode == 'H7K9M2X4') {
        emit(AuthSuccess(
          institutionId: 'inst_123',
          userData: {'name': 'John Doe', 'class': '10A'},
        ));
      } else {
        emit(AuthFailure('Invalid verification code. Please try again.'));
      }
    } catch (e) {
      emit(AuthFailure('Something went wrong. Please try again.'));
    }
  }

  void _onReset(AuthReset event, Emitter<AuthState> emit) {
    emit(AuthInitial());
    _currentCode = '';
  }
}
