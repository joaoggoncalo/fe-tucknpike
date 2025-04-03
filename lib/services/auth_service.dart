import 'dart:convert';

import 'package:fe_tucknpike/config.dart';
import 'package:fe_tucknpike/services/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// AuthService handles authentication-related operations.
class AuthService {
  /// Singleton constructor.
  factory AuthService() => _instance;
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();

  /// Base URL for the API.
  final String baseUrl = AppConfig.baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();
  String? _cachedToken;

  /// Initializes the AuthService by reading the token from secure storage.
  Future<void> init() async {
    _cachedToken = await _storage.read(key: 'jwt_token');
  }

  /// Checks if the user is logged in.
  bool get isLoggedIn => _cachedToken != null;

  /// Checks if the token is expired.
  String? get userRole {
    if (_cachedToken == null) return null;
    final decodedToken = JwtDecoder.decode(_cachedToken!);
    return decodedToken['role'] as String?;
  }

  /// Checks if the token is expired.
  String? get username {
    if (_cachedToken == null) return null;
    final decodedToken = JwtDecoder.decode(_cachedToken!);
    return decodedToken['username'] as String?;
  }

  /// Logs in a user with the provided username or email and password.
  Future<String?> login(String usernameOrEmail, String password) async {
    final response = await _apiClient.request(
      endpoint: 'auth/login',
      method: 'POST',
      body: {
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      },
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

  /// Registers a new user and creates a gymnast or coach record.
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String name,
    required String dateOfBirth,
    required String clubName,
    required String role,
  }) async {
    final response = await _apiClient.request(
      endpoint: 'auth/register',
      method: 'POST',
      body: {
        'username': username,
        'email': email,
        'password': password,
        'name': name,
        'dateOfBirth': dateOfBirth,
        'clubName': clubName,
        'role': role,
      },
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception({response.body});
    }

    final newUser = jsonDecode(response.body) as Map<String, dynamic>;
    final newUserId = newUser['id'] as String;

    await login(username, password);

    if (role.toLowerCase() == 'gymnast') {
      final gymnastResponse = await _apiClient.request(
        endpoint: 'gymnasts',
        method: 'POST',
        body: {
          'userId': newUserId,
          'trainingIds': <String>[],
          'username': username,
        },
      );
      if (gymnastResponse.statusCode != 201 &&
          gymnastResponse.statusCode != 200) {
        throw Exception(
          'Failed to create gymnast record: ${gymnastResponse.body}',
        );
      }
    } else if (role.toLowerCase() == 'coach') {
      final coachResponse = await _apiClient.request(
        endpoint: 'coaches',
        method: 'POST',
        body: {
          'userId': newUserId,
          'gymnasts': <String>[],
          'username': username,
        },
      );
      if (coachResponse.statusCode != 201 && coachResponse.statusCode != 200) {
        throw Exception('Failed to create coach record: ${coachResponse.body}');
      }
    }
  }

  /// Fetches the user ID from the token.
  Future<String?> getToken() async {
    return _storage.read(key: 'jwt_token');
  }

  /// Fetches the user ID from the token.
  Future<void> logout() async {
    _cachedToken = null;
    await _storage.delete(key: 'jwt_token');
  }
}
