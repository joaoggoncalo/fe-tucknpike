/// This is a Dart class that represents an exercise.
class Exercise {
  /// Creates an [Exercise] object.
  Exercise({required this.name, required this.completed});

  /// Creates an [Exercise] object from a JSON map.
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] as String,
      completed: json['completed'] as bool,
    );
  }

  /// The name of the exercise.
  final String name;

  /// Indicates whether the exercise is completed.
  final bool completed;
}
