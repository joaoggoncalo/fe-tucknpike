import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// A class that provides methods to interact with secure storage.
class AuthStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  /// Retrieves the JWT token from secure storage.
  static Future<String> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) {
      throw Exception('No token found');
    }
    return token;
  }

  /// Saves the JWT token to secure storage.
  static Future<String> getUserId() async {
    final token = await getToken();
    final decodedToken = JwtDecoder.decode(token);
    return decodedToken['sub'] as String;
  }
}
