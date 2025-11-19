import 'package:dio/dio.dart';
import '../../storage/auth_storage.dart';

/// Interceptor to inject auth token into requests
class AuthInterceptor extends Interceptor {
  final AuthStorage authStorage;

  AuthInterceptor(this.authStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = authStorage.getAccessToken();

    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    super.onRequest(options, handler);
  }
}
