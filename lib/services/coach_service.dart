import 'dart:convert';
import 'package:fe_tucknpike/models/trainings.dart';
import 'package:fe_tucknpike/services/api_client.dart';
import 'package:fe_tucknpike/stores/auth_storage.dart';

/// CoachService provides methods to interact with coach-related data.
class CoachService {
  final ApiClient _apiClient = ApiClient();

  /// Get a list of gymnasts for a coach.
  Future<List<dynamic>> getGymnasts() async {
    final coachUserId = await AuthStorage.getUserId();

    final response = await _apiClient.request(
      endpoint: 'coaches/$coachUserId',
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['gymnasts'] as List<dynamic>;
    } else {
      throw Exception('Failed to load gymnasts for coach: ${response.body}');
    }
  }

  /// Get a list of all gymnasts.
  Future<List<dynamic>> getAllGymnasts() async {
    final response = await _apiClient.request(
      endpoint: 'gymnasts',
      method: 'GET',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Assuming the response returns a JSON list.
      return data as List<dynamic>;
    } else {
      throw Exception('Failed to load all gymnasts ${response.body}');
    }
  }

  /// Add a gymnast to the coach.
  Future<void> addGymnast(String gymnastUserId) async {
    final coachUserId = await AuthStorage.getUserId();

    final response = await _apiClient.request(
      endpoint: 'coaches/$coachUserId/gymnasts/$gymnastUserId',
      method: 'POST',
      body: {},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add gymnast ${response.body}');
    }
  }

  /// Update the season goal for a gymnast.
  Future<void> updateSeasonGoal(String gymnastUserId, String seasonGoal) async {
    final response = await _apiClient.request(
      endpoint: 'gymnasts/$gymnastUserId/season-goals',
      method: 'PUT',
      body: {'seasonGoals': seasonGoal},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update season goal ${response.body}');
    }
  }

  /// Remove a gymnast from the coach.
  Future<List<Training>> getAthletesTrainings() async {
    final response = await _apiClient.request(
      endpoint: 'trainings/my-athletes-trainings',
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
