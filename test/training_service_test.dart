// File: lib/services/trainings_service.dart
import 'package:fe_tucknpike/services/api_client.dart';

/// This class handles the training-related operations.
class TrainingService {
  final ApiClient _apiClient;

  TrainingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Updates the completed status of each exercise.
  Future<void> updateExerciseStatus(
    String trainingId,
    List<Map<String, dynamic>> exercises,
  ) async {
    final response = await _apiClient.request(
      endpoint: 'trainings/$trainingId/exercises/status',
      method: 'PUT',
      body: {'exercises': exercises},
    );
    if (response.statusCode != 200) {
      throw Exception('Error updating exercise status: ${response.body}');
    }
  }

  /// Adds additional exercises.
  Future<void> addExercises(String trainingId, List<String> exercises) async {
    final response = await _apiClient.request(
      endpoint: 'trainings/$trainingId/exercises/add',
      method: 'PUT',
      body: {'exercises': exercises},
    );
    if (response.statusCode != 200) {
      throw Exception('Error adding exercises: ${response.body}');
    }
  }

  /// Updates the overall training status to missed or completed.
  Future<void> updateTrainingStatus(String trainingId, String status) async {
    final response = await _apiClient.request(
      endpoint: 'trainings/$trainingId/status',
      method: 'PUT',
      body: {'status': status},
    );
    if (response.statusCode != 200) {
      throw Exception('Error updating training status: ${response.body}');
    }
  }

  /// Updates the training location.
  Future<void> updateTrainingLocation(
    String trainingId,
    Map<String, dynamic> location,
  ) async {
    final response = await _apiClient.request(
      endpoint: 'trainings/$trainingId/location',
      method: 'PUT',
      body: {'location': location},
    );
    if (response.statusCode != 200) {
      throw Exception('Error updating location: ${response.body}');
    }
  }

  /// Creates a new training session.
  Future<void> createTraining({
    required String userId,
    required List<String> exercises,
    required DateTime date,
    String? coachId,
  }) async {
    final body = {
      'userId': userId,
      if (coachId != null) 'coachId': coachId,
      'exercises': exercises,
      'date': DateTime(date.year, date.month, date.day, 14).toIso8601String(),
      'location': <String, dynamic>{},
    };

    final response = await _apiClient.request(
      endpoint: 'trainings',
      method: 'POST',
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error creating training: ${response.body}');
    }
  }
}
