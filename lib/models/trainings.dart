import 'package:fe_tucknpike/models/exercise.dart';

/// This class represents a training session.
class Training {
  /// Creates a [Training] object.
  Training({
    required this.trainingId,
    required this.userId,
    required this.exercises,
    required this.date,
    required this.location,
    required this.status,
    this.coachId,
  });

  /// Creates a [Training] object from a JSON map.
  factory Training.fromJson(Map<String, dynamic> json) {
    var exercisesList = <Exercise>[];
    final exercisesJson = json['exercises'];

    if (exercisesJson is List) {
      exercisesList = exercisesJson
          .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (exercisesJson is Map && exercisesJson.isEmpty) {
      exercisesList = [];
    }

    return Training(
      trainingId: json['trainingId'] as String,
      userId: json['userId'] as String,
      coachId: json['coachId'] as String?,
      exercises: exercisesList,
      date: DateTime.parse(json['date'] as String),
      location: json['location'] as Map<String, dynamic>,
      status: json['status'] as String,
    );
  }

  /// The ID of the training session.
  final String trainingId;

  /// The ID of the user associated with the training session.
  final String userId;

  /// The ID of the coach associated with the training session.
  final String? coachId;

  /// The list of exercises in the training session.
  final List<Exercise> exercises;

  /// The date of the training session
  final DateTime date;

  /// The location of the training session.
  final Map<String, dynamic> location;

  /// The status of the training session.
  final String status;
}
