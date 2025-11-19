import 'package:dio/dio.dart';
import '../../storage/auth_storage.dart';

/// Interceptor to handle automatic token refresh on 401 errors
class TokenRefreshInterceptor extends Interceptor {
  final Dio dio;
  final AuthStorage authStorage;
  final Function() onTokenExpired; // Callback to logout user

  TokenRefreshInterceptor({
    required this.dio,
    required this.authStorage,
    required this.onTokenExpired,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if error is 401 Unauthorized
    if (err.response?.statusCode == 401) {
      final refreshToken = authStorage.getRefreshToken();

      // If we have a refresh token, try to refresh
      if (refreshToken != null) {
        try {
          // Note: The API doesn't have a refresh endpoint in the provided spec
          // So we'll just call the onTokenExpired callback to logout
          // If a refresh endpoint exists, implement it here
          onTokenExpired();
          return handler.reject(err);
        } catch (e) {
          // Refresh failed, logout user
          onTokenExpired();
          return handler.reject(err);
        }
      } else {
        // No refresh token, logout user
        onTokenExpired();
        return handler.reject(err);
      }
    }

    super.onError(err, handler);
  }
}
