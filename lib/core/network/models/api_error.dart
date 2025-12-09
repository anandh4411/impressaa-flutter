/// API error model
class ApiError {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiError({
    required this.message,
    this.statusCode,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? 'An error occurred',
      statusCode: json['statusCode'],
      details: json['details'],
    );
  }

  @override
  String toString() {
    return 'ApiError(message: $message, statusCode: $statusCode)';
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final ApiError error;

  ApiException(this.error);

  @override
  String toString() => error.toString();
}
