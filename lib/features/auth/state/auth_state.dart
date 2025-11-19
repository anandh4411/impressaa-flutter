import 'auth_event.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {
  final LoginMethod currentMethod;
  final String institutionCode;
  final String loginCode;
  final String idNumber;

  AuthInitial({
    this.currentMethod = LoginMethod.institutionCode,
    this.institutionCode = '',
    this.loginCode = '',
    this.idNumber = '',
  });

  AuthInitial copyWith({
    LoginMethod? currentMethod,
    String? institutionCode,
    String? loginCode,
    String? idNumber,
  }) {
    return AuthInitial(
      currentMethod: currentMethod ?? this.currentMethod,
      institutionCode: institutionCode ?? this.institutionCode,
      loginCode: loginCode ?? this.loginCode,
      idNumber: idNumber ?? this.idNumber,
    );
  }
}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}
