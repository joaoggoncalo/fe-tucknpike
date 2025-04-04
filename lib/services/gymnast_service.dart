import 'dart:convert';
import 'package:fe_tucknpike/models/trainings.dart';
import 'package:fe_tucknpike/services/api_client.dart';

/// Fetches the trainings for the current user using the
/// new endpoint "my-trainings".
class GymnastService {
  final ApiClient _apiClient = ApiClient();

  /// Calls the "my-trainings" endpoint and
  /// returns all trainings for the current user.
  Future<List<Training>> getTrainings() async {
    print('get trainings');
    final response = await _apiClient.request(
      endpoint: 'trainings/my-trainings',
      method: 'GET',
    );
    print('response: ${response.body}');
    print('status code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonList = jsonDecode(response.body) as List<dynamic>;
      final trainings = jsonList
          .map((item) => Training.fromJson(item as Map<String, dynamic>))
          .toList();
      return trainings;
    } else {
      return [];
    }
  }
}
