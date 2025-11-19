import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  final SharedPreferences _prefs;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  AuthStorage(this._prefs);

  /// Save authentication tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresInSeconds,
  }) async {
    await _prefs.setString(_accessTokenKey, accessToken);
    await _prefs.setString(_refreshTokenKey, refreshToken);

    // Calculate expiry timestamp
    final expiryTimestamp = DateTime.now()
        .add(Duration(seconds: expiresInSeconds))
        .millisecondsSinceEpoch;
    await _prefs.setInt(_tokenExpiryKey, expiryTimestamp);
  }

  /// Get access token
  String? getAccessToken() {
    return _prefs.getString(_accessTokenKey);
  }

  /// Get refresh token
  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  /// Check if user is authenticated (has valid tokens)
  bool isAuthenticated() {
    final accessToken = getAccessToken();
    final refreshToken = getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  /// Check if access token is expired
  bool isAccessTokenExpired() {
    final expiryTimestamp = _prefs.getInt(_tokenExpiryKey);
    if (expiryTimestamp == null) return true;

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
    return DateTime.now().isAfter(expiryDate);
  }

  /// Clear all authentication data
  Future<void> clearAuth() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_tokenExpiryKey);
  }
}
