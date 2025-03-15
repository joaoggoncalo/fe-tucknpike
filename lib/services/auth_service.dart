import 'dart:convert';

import 'package:fe_tucknpike/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// AuthService class handles authentication-related operations
/// such as login, registration,
/// token retrieval, and logout.
class AuthService {
  /// Base URL for the authentication API, retrieved from AppConfig.
  final String baseUrl = AppConfig.baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Login method to authenticate a user with username or email and password.
  /// Returns a JWT token if successful.
  Future<String?> login(String usernameOrEmail, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final token = data['token'] as String;
      await _storage.write(key: 'jwt_token', value: token);
      return token;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  /// Register method to create a new user account.
  /// Throws an exception if registration fails.
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String name,
    required String dateOfBirth,
    required String clubName,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'name': name,
        'dateOfBirth': dateOfBirth,
        'clubName': clubName,
        'role': role,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  /// Retrieve JWT token from secure storage.
  Future<String?> getToken() async {
    return _storage.read(key: 'jwt_token');
  }

  /// Logout method to delete the JWT token from secure storage.
  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}
