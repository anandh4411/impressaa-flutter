abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String institutionId;
  final Map<String, dynamic> userData;

  AuthSuccess({
    required this.institutionId,
    required this.userData,
  });
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthCodeValidation extends AuthState {
  final String code;
  final bool isValid;
  final String? errorMessage;

  AuthCodeValidation({
    required this.code,
    required this.isValid,
    this.errorMessage,
  });
}
