abstract class AuthEvent {}

class VerifyCodeSubmitted extends AuthEvent {
  final String code;

  VerifyCodeSubmitted(this.code);
}

class CodeChanged extends AuthEvent {
  final String code;

  CodeChanged(this.code);
}
