import 'dart:convert';
import 'package:fe_tucknpike/config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// AuthService class handles authentication-related operations.
class AuthService {
  /// Singleton instance of the [AuthService] class.
  factory AuthService() => _instance;
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();

  /// Base URL for the authentication API, retrieved from AppConfig.
  final String baseUrl = AppConfig.baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _cachedToken;

  /// Returns true if a token exists in memory.
  bool get isLoggedIn => _cachedToken != null;

  /// Login method to authenticate a user with username/email and password.
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
      _cachedToken = token;
      await _storage.write(key: 'jwt_token', value: token);
      return token;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  /// Register method to create a new user account
  /// and add a role-specific record.
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String name,
    required String dateOfBirth,
    required String clubName,
    required String role,
  }) async {
    // First, register the user through the auth endpoint.
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

    // Parse the newly created user data.
    final newUser = jsonDecode(response.body) as Map<String, dynamic>;
    final newUserId = newUser['id'] as String;

    // If the role is "gymnast", post to the gymnasts endpoint.
    if (role.toLowerCase() == 'gymnast') {
      final gymnastResponse = await http.post(
        Uri.parse('$baseUrl/gymnasts'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': newUserId,
          'trainingIds': <String>[],
        }),
      );
      if (gymnastResponse.statusCode != 201 &&
          gymnastResponse.statusCode != 200) {
        throw Exception(
          'Failed to create gymnast record: ${gymnastResponse.body}',
        );
      }
    }
    // If the role is "coach", post to the coaches endpoint.
    else if (role.toLowerCase() == 'coach') {
      final coachResponse = await http.post(
        Uri.parse('$baseUrl/coaches'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': newUserId,
          'gymnasts': <String>[],
        }),
      );
      if (coachResponse.statusCode != 201 && coachResponse.statusCode != 200) {
        throw Exception('Failed to create coach record: ${coachResponse.body}');
      }
    }
  }

  /// Retrieve JWT token from secure storage.
  Future<String?> getToken() async {
    return _storage.read(key: 'jwt_token');
  }

  /// Logout method to delete the JWT token from secure storage.
  Future<void> logout() async {
    _cachedToken = null;
    await _storage.delete(key: 'jwt_token');
  }
}
