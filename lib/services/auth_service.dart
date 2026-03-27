import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://api.markahendricks.com/api';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String usernameKey = 'username';

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final Uri url = Uri.parse('$baseUrl/register/');

      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (kDebugMode) {
        debugPrint('REGISTER STATUS: ${response.statusCode}');
        debugPrint('REGISTER BODY: ${response.body}');
      }

      return response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('REGISTER ERROR: $e');
      }
      rethrow;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      final Uri url = Uri.parse('$baseUrl/token/');

      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (kDebugMode) {
        debugPrint('LOGIN STATUS: ${response.statusCode}');
        debugPrint('LOGIN BODY: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        await _storage.write(key: accessTokenKey, value: data['access']);
        await _storage.write(key: refreshTokenKey, value: data['refresh']);
        await _storage.write(key: usernameKey, value: username);

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('LOGIN ERROR: $e');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
    await _storage.delete(key: usernameKey);
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _storage.read(key: refreshTokenKey);
  }

  Future<String?> getUsername() async {
    return _storage.read(key: usernameKey);
  }

  Future<bool> isLoggedIn() async {
    final String? token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> refreshAccessToken() async {
    try {
      final String? refreshToken = await getRefreshToken();

      if (refreshToken == null) {
        return false;
      }

      final Uri url = Uri.parse('$baseUrl/token/refresh/');

      final http.Response response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh': refreshToken,
        }),
      );

      if (kDebugMode) {
        debugPrint('REFRESH STATUS: ${response.statusCode}');
        debugPrint('REFRESH BODY: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        await _storage.write(key: accessTokenKey, value: data['access']);
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('REFRESH ERROR: $e');
      }
      return false;
    }
  }
}