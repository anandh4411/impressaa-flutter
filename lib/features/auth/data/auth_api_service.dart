import '../../../core/network/api_client.dart';
import '../../../core/network/models/api_response.dart';
import '../../../core/network/models/auth_models.dart';

class AuthApiService {
  final ApiClient apiClient;

  AuthApiService(this.apiClient);

  /// Login with institution code + id number
  Future<AuthTokenResponse> loginWithInstitutionCode({
    required String institutionCode,
    required String idNumber,
  }) async {
    final request = LoginWithInstitutionCodeRequest(
      institutionCode: institutionCode,
      idNumber: idNumber,
    );

    final response = await apiClient.post(
      '/mobile/auth/login',
      data: request.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => AuthTokenResponse.fromJson(data),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Login failed');
    }

    return apiResponse.data!;
  }

  /// Login with login code only
  Future<AuthTokenResponse> loginWithLoginCode({
    required String loginCode,
  }) async {
    final request = LoginWithLoginCodeRequest(
      loginCode: loginCode,
    );

    final response = await apiClient.post(
      '/mobile/auth/login',
      data: request.toJson(),
    );

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => AuthTokenResponse.fromJson(data),
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message ?? 'Login failed');
    }

    return apiResponse.data!;
  }

  /// Logout (revoke refresh token)
  Future<void> logout(String refreshToken) async {
    final request = LogoutRequest(refreshToken: refreshToken);

    await apiClient.post(
      '/mobile/auth/logout',
      data: request.toJson(),
    );
  }
}
