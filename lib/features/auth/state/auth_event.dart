abstract class AuthEvent {}

class AuthCodeChanged extends AuthEvent {
  final String code;
  AuthCodeChanged(this.code);
}

class AuthSubmitted extends AuthEvent {}

class AuthReset extends AuthEvent {}
