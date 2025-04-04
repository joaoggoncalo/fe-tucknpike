// dart
import 'package:fe_tucknpike/services/geocoding_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:fe_tucknpike/models/trainings.dart';
import 'package:fe_tucknpike/models/exercise.dart';
import 'package:fe_tucknpike/services/trainings_service.dart';

class TrainingDetailPage extends StatefulWidget {
  final Training training;
  final bool fromProfile;

  const TrainingDetailPage({
    Key? key,
    required this.training,
    this.fromProfile = false,
  }) : super(key: key);

  @override
  _TrainingDetailPageState createState() => _TrainingDetailPageState();
}

class _TrainingDetailPageState extends State<TrainingDetailPage> {
  late List<Exercise> _exercises;
  final TrainingService _trainingService = TrainingService();
  final TextEditingController _newExerciseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _exercises = List<Exercise>.from(widget.training.exercises);
  }

  @override
  void dispose() {
    _newExerciseController.dispose();
    super.dispose();
  }

  Future<void> _toggleExercise(int index) async {
    setState(() {
      _exercises[index] = _exercises[index].copyWith(
        completed: !_exercises[index].completed,
      );
    });
    try {
      final exercisesData = _exercises
          .map((e) => {'name': e.name, 'completed': e.completed})
          .toList();
      await _trainingService.updateExerciseStatus(
          widget.training.trainingId, exercisesData);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise status updated')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating exercise: $e')));
    }
  }

  Future<void> _submitNewExercise() async {
    final newName = _newExerciseController.text.trim();
    if (newName.isEmpty) return;
    try {
      await _trainingService
          .addExercises(widget.training.trainingId, [newName]);
      setState(() {
        _exercises.add(Exercise(name: newName, completed: false));
        _newExerciseController.clear();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('New exercise added')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding exercise: $e')));
    }
  }

  Future<void> _updateTrainingStatus(String status) async {
    try {
      await _trainingService.updateTrainingStatus(
          widget.training.trainingId, status);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Training marked as $status')));
      context.go('/trainings');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating training status: $e')));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // Check current permission status.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _updateLocation() async {
    try {
      // Get current position and request permission if needed.
      final position = await _determinePosition();

      // Perform reverse geocoding to get the address from coordinates.

      final address = await GeocodingService()
          .getAddress(position.latitude, position.longitude);

      final location = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
      };

      await _trainingService.updateTrainingLocation(
          widget.training.trainingId, location);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated successfully')));
    } catch (e) {
      print('error: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating location: $e')));
    }
  }

  bool get _hasCompletedExercise =>
      _exercises.any((exercise) => exercise.completed);

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMM d, yyyy').format(widget.training.date);
    final isScheduled = widget.training.status.toLowerCase() == 'scheduled';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.fromProfile) {
              context.go('/profile');
            } else if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/trainings');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Training ID: ${widget.training.trainingId}',
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text('User ID: ${widget.training.userId}',
                  style: const TextStyle(fontSize: 18)),
              if (widget.training.coachId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Coach ID: ${widget.training.coachId}',
                      style: const TextStyle(fontSize: 18)),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text('Date: $formattedDate',
                    style: const TextStyle(fontSize: 18)),
              ),
              Text('Status: ${widget.training.status}',
                  style: const TextStyle(fontSize: 18)),
              Text('Location: ${widget.training.location['address'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18)),
              if (widget.training.gymnastUsername != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Gymnast: ${widget.training.gymnastUsername}',
                      style: const TextStyle(fontSize: 18)),
                ),
              const SizedBox(height: 16),
              const Text('Exercises:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ..._exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return CheckboxListTile(
                  title: Text(exercise.name),
                  value: exercise.completed,
                  onChanged: isScheduled ? (_) => _toggleExercise(index) : null,
                );
              }).toList(),
              if (isScheduled) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newExerciseController,
                        decoration: const InputDecoration(
                          hintText: 'Enter new exercise name',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _submitNewExercise(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submitNewExercise,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final status =
                        _hasCompletedExercise ? 'completed' : 'missed';
                    await _updateTrainingStatus(status);
                  },
                  child: Text(_hasCompletedExercise
                      ? 'Complete Training'
                      : 'Missed Training'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateLocation,
                  child: const Text('Update Location'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
