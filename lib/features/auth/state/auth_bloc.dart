import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../data/auth_api_service.dart';
import '../../../core/storage/auth_storage.dart';
import '../../../core/network/models/api_error.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiService authApiService;
  final AuthStorage authStorage;

  AuthBloc({
    required this.authApiService,
    required this.authStorage,
  }) : super(AuthInitial()) {
    on<AuthLoginMethodChanged>(_onLoginMethodChanged);
    on<AuthInstitutionCodeChanged>(_onInstitutionCodeChanged);
    on<AuthLoginCodeChanged>(_onLoginCodeChanged);
    on<AuthIdNumberChanged>(_onIdNumberChanged);
    on<AuthSubmitted>(_onSubmitted);
    on<AuthReset>(_onReset);
  }

  void _onLoginMethodChanged(
    AuthLoginMethodChanged event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthInitial) {
      final currentState = state as AuthInitial;
      emit(currentState.copyWith(currentMethod: event.method));
    }
  }

  void _onInstitutionCodeChanged(
    AuthInstitutionCodeChanged event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthInitial) {
      final currentState = state as AuthInitial;
      emit(currentState.copyWith(
        institutionCode: event.institutionCode.toUpperCase(),
      ));
    }
  }

  void _onLoginCodeChanged(
    AuthLoginCodeChanged event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthInitial) {
      final currentState = state as AuthInitial;
      emit(currentState.copyWith(
        loginCode: event.loginCode.toUpperCase(),
      ));
    }
  }

  void _onIdNumberChanged(
    AuthIdNumberChanged event,
    Emitter<AuthState> emit,
  ) {
    if (state is AuthInitial) {
      final currentState = state as AuthInitial;
      emit(currentState.copyWith(idNumber: event.idNumber));
    }
  }

  Future<void> _onSubmitted(
    AuthSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthInitial) return;

    final currentState = state as AuthInitial;
    emit(AuthLoading());

    try {
      // Determine which login method to use
      if (currentState.currentMethod == LoginMethod.institutionCode) {
        // Validate inputs
        if (currentState.institutionCode.isEmpty) {
          emit(AuthFailure('Please enter institution code'));
          emit(currentState);
          return;
        }
        if (currentState.idNumber.isEmpty) {
          emit(AuthFailure('Please enter your ID number'));
          emit(currentState);
          return;
        }

        // Call API with institution code
        final response = await authApiService.loginWithInstitutionCode(
          institutionCode: currentState.institutionCode,
          idNumber: currentState.idNumber,
        );

        // Save tokens
        await authStorage.saveTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          expiresInSeconds: response.accessTokenExpiresIn,
        );

        emit(AuthSuccess());
      } else {
        // Login with login code
        if (currentState.loginCode.isEmpty) {
          emit(AuthFailure('Please enter login code'));
          emit(currentState);
          return;
        }
        if (currentState.idNumber.isEmpty) {
          emit(AuthFailure('Please enter your ID number'));
          emit(currentState);
          return;
        }

        // Call API with login code
        final response = await authApiService.loginWithLoginCode(
          loginCode: currentState.loginCode,
          idNumber: currentState.idNumber,
        );

        // Save tokens
        await authStorage.saveTokens(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          expiresInSeconds: response.accessTokenExpiresIn,
        );

        emit(AuthSuccess());
      }
    } on ApiException catch (e) {
      emit(AuthFailure(e.error.message));
      emit(currentState);
    } catch (e) {
      emit(AuthFailure('Login failed. Please try again.'));
      emit(currentState);
    }
  }

  void _onReset(AuthReset event, Emitter<AuthState> emit) {
    emit(AuthInitial());
  }
}
