abstract class AuthEvent {}

/// Event to toggle between login methods
class AuthLoginMethodChanged extends AuthEvent {
  final LoginMethod method;
  AuthLoginMethodChanged(this.method);
}

/// Event when institution code changes
class AuthInstitutionCodeChanged extends AuthEvent {
  final String institutionCode;
  AuthInstitutionCodeChanged(this.institutionCode);
}

/// Event when login code changes
class AuthLoginCodeChanged extends AuthEvent {
  final String loginCode;
  AuthLoginCodeChanged(this.loginCode);
}

/// Event when ID number changes
class AuthIdNumberChanged extends AuthEvent {
  final String idNumber;
  AuthIdNumberChanged(this.idNumber);
}

/// Event to submit login
class AuthSubmitted extends AuthEvent {}

/// Event to reset auth state
class AuthReset extends AuthEvent {}

/// Login method enum
enum LoginMethod {
  institutionCode,
  loginCode,
}
