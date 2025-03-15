import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A class that provides application configuration settings.
class AppConfig {
  /// Gets the base URL from the environment variables.
  ///
  /// Throws an [Exception] if the `BASE_URL` is not set in the `.env` file.
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('BASE_URL is not set in the .env file');
    }
    return url;
  }
}
