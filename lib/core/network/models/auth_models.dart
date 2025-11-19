/// Auth token response model
class AuthTokenResponse {
  final String accessToken;
  final String refreshToken;
  final int accessTokenExpiresIn;

  AuthTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresIn,
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      accessTokenExpiresIn: json['accessTokenExpiresIn'] as int,
    );
  }
}

/// Login request with institution code
class LoginWithInstitutionCodeRequest {
  final String institutionCode;
  final String idNumber;

  LoginWithInstitutionCodeRequest({
    required this.institutionCode,
    required this.idNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'institutionCode': institutionCode,
      'idNumber': idNumber,
    };
  }
}

/// Login request with login code
class LoginWithLoginCodeRequest {
  final String loginCode;
  final String idNumber;

  LoginWithLoginCodeRequest({
    required this.loginCode,
    required this.idNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'loginCode': loginCode,
      'idNumber': idNumber,
    };
  }
}

/// Logout request
class LogoutRequest {
  final String refreshToken;

  LogoutRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {
      'refreshToken': refreshToken,
    };
  }
}
