import 'package:fe_tucknpike/services/api_client.dart';

/// This class handles the training-related operations.
class TrainingService {
  final ApiClient _apiClient = ApiClient();

  /// Updates the completed status of each exercise.
  /// Endpoint: PUT /trainings/{trainingId}/exercises/status
  Future<void> updateExerciseStatus(
      String trainingId, List<Map<String, dynamic>> exercises) async {
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
  /// Endpoint: PUT /trainings/{trainingId}/exercises/add
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
  /// Endpoint: PUT /trainings/{trainingId}/status
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
}
