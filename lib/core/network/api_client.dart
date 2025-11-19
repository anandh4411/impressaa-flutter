import 'package:dio/dio.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/token_refresh_interceptor.dart';
import 'models/api_error.dart';
import '../storage/auth_storage.dart';

class ApiClient {
  late final Dio _dio;
  final AuthStorage authStorage;
  final Function() onTokenExpired;

  // API Configuration
  static const String baseUrl = 'https://impressaa.com';
  static const String apiVersion = '/v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  ApiClient({
    required this.authStorage,
    required this.onTokenExpired,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: '$baseUrl$apiVersion',
        connectTimeout: connectionTimeout,
        receiveTimeout: receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(AuthInterceptor(authStorage));
    _dio.interceptors.add(
      TokenRefreshInterceptor(
        dio: _dio,
        authStorage: authStorage,
        onTokenExpired: onTokenExpired,
      ),
    );

    // Add logging interceptor in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to ApiException
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          ApiError(
            message: 'Connection timeout. Please check your internet connection.',
            statusCode: null,
          ),
        );

      case DioExceptionType.badResponse:
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          // API returns error in nested structure: { success: false, error: { message: '...' } }
          final errorData = data['error'] as Map<String, dynamic>?;
          final message = errorData?['message'] ??
                         data['message'] ??
                         'An error occurred';

          return ApiException(
            ApiError(
              message: message,
              statusCode: error.response?.statusCode,
              details: data,
            ),
          );
        }
        return ApiException(
          ApiError(
            message: 'Server error occurred',
            statusCode: error.response?.statusCode,
          ),
        );

      case DioExceptionType.cancel:
        return ApiException(
          ApiError(message: 'Request cancelled'),
        );

      case DioExceptionType.connectionError:
        return ApiException(
          ApiError(
            message: 'No internet connection. Please check your network.',
          ),
        );

      default:
        return ApiException(
          ApiError(
            message: error.message ?? 'An unexpected error occurred',
          ),
        );
    }
  }
}
