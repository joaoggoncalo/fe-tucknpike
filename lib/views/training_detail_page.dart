import 'package:fe_tucknpike/constants/brand_colors.dart';
import 'package:fe_tucknpike/models/exercise.dart';
import 'package:fe_tucknpike/models/trainings.dart';
import 'package:fe_tucknpike/services/geocoding_service.dart';
import 'package:fe_tucknpike/services/trainings_service.dart';
import 'package:fe_tucknpike/stores/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// TrainingDetailPage displays the details of a specific training session.
class TrainingDetailPage extends StatefulWidget {
  /// Creates a TrainingDetailPage.
  const TrainingDetailPage({
    required this.training,
    super.key,
    this.fromProfile = false,
  });

  /// training is the training object to be displayed.
  final Training training;

  /// fromProfile indicates if the page is accessed from the profile (owner).
  final bool fromProfile;

  @override
  State<TrainingDetailPage> createState() => _TrainingDetailPageState();
}

class _TrainingDetailPageState extends State<TrainingDetailPage> {
  late List<Exercise> _exercises;
  final TrainingService _trainingService = TrainingService();
  final TextEditingController _newExerciseController = TextEditingController();
  bool _canEdit = false;
  bool _isUpdatingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeCanEdit();
    _exercises = List<Exercise>.from(widget.training.exercises);
  }

  @override
  void dispose() {
    _newExerciseController.dispose();
    super.dispose();
  }

  Future<void> _initializeCanEdit() async {
    final userId = await AuthStorage.getUserId();
    setState(() {
      _canEdit = widget.training.userId == userId;
    });
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
        widget.training.trainingId,
        exercisesData,
      );
    } on Exception catch (e) {
      if (!mounted) return;
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
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('New exercise added')));
    } on Exception catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error adding exercise: $e')));
    }
  }

  Future<void> _updateTrainingStatus(String status) async {
    try {
      await _trainingService.updateTrainingStatus(
        widget.training.trainingId,
        status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Training marked as $status')));
      context.go('/trainings');
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating training status: $e')),
      );
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
        'Location permissions are permanently denied, cannot request permissions.',
      );
    }

    ///
    return Geolocator.getCurrentPosition(
      /// Ignoring the deprecation warning for now.
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _updateLocation() async {
    setState(() {
      _isUpdatingLocation = true;
    });
    try {
      final position = await _determinePosition();
      final address = await GeocodingService()
          .getAddress(position.latitude, position.longitude);
      final location = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
      };

      await _trainingService.updateTrainingLocation(
        widget.training.trainingId,
        location,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated successfully'),
        ),
      );
    } on Exception catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating location: $e')));
    } finally {
      setState(() {
        _isUpdatingLocation = false;
      });
    }
  }

  bool get _hasCompletedExercise =>
      _exercises.any((exercise) => exercise.completed);

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMM d, yyyy').format(widget.training.date);
    final isScheduled = widget.training.status.toLowerCase() == 'scheduled';
    final canEdit = _canEdit;

    return Scaffold(
      backgroundColor: BrandColors.backgroundColor,
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Training summary card
              Card(
                color: BrandColors.cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Training ID: ${widget.training.trainingId}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'User ID: ${widget.training.userId}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (widget.training.coachId != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Coach ID: ${widget.training.coachId}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Date: $formattedDate',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Status: ${widget.training.status}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Location: ${widget.training.location['address'] ?? 'N/A'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (widget.training.gymnastUsername != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Gymnast: ${widget.training.gymnastUsername}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              // Exercises section
              const Text(
                'Exercises:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: BrandColors.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: BrandColors.cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _exercises.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exercise = entry.value;
                      return CheckboxListTile(
                        title: Text(exercise.name),
                        value: exercise.completed,
                        activeColor: BrandColors.accentColor,
                        onChanged: canEdit && isScheduled
                            ? (_) => _toggleExercise(index)
                            : null,
                      );
                    }).toList(),
                  ),
                ),
              ),
              // New exercise input and editing controls (only displayed if editing is allowed)
              if (isScheduled && canEdit) ...[
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BrandColors.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(color: BrandColors.lightAccent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Complete or missed training button
                ElevatedButton(
                  onPressed: () async {
                    final status =
                        _hasCompletedExercise ? 'completed' : 'missed';
                    await _updateTrainingStatus(status);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    _hasCompletedExercise
                        ? 'Complete Training'
                        : 'Missed Training',
                    style: const TextStyle(
                      fontSize: 16,
                      color: BrandColors.lightAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Update location button
                ElevatedButton(
                  onPressed: _updateLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BrandColors.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: _isUpdatingLocation
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            BrandColors.lightAccent,
                          ),
                        )
                      : const Text(
                          'Update Location',
                          style: TextStyle(
                            fontSize: 16,
                            color: BrandColors.lightAccent,
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
