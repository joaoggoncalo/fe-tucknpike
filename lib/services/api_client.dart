import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// ApiClient class handles HTTP requests to the API.
class ApiClient {
  /// baseUrl for the API.
  final String baseUrl = dotenv.env['BASE_URL']!;

  /// apiKey for the API.
  final String apiKey = dotenv.env['API_KEY']!;

  Future<http.Response> request({
    required String endpoint,
    required String method,
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
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
