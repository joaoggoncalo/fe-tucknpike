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
    final response = await _apiClient.request(
      endpoint: 'trainings/my-trainings',
      method: 'GET',
    );

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
