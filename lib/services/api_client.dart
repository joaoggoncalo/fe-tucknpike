import 'dart:convert';

import 'package:fe_tucknpike/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// ApiClient now uses the JWT token (if available) for secured endpoints.
class ApiClient {
  /// The base URL for the API.
  final String baseUrl =
      kIsWeb ? dotenv.env['WEB_URL']! : dotenv.env['BASE_URL']!;

  /// Make an HTTP request to the API.
  Future<http.Response> request({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');

    final token = await AuthService().getToken();

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return http.get(url, headers: headers);
      case 'POST':
        return http.post(url, headers: headers, body: jsonEncode(body));
      case 'PUT':
        return http.put(url, headers: headers, body: jsonEncode(body));
      case 'DELETE':
        return http.delete(url, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }
}
