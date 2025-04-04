// File: lib/views/create_training_page.dart
import 'package:fe_tucknpike/constants/brand_colors.dart';
import 'package:fe_tucknpike/services/trainings_service.dart';
import 'package:fe_tucknpike/stores/auth_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// CreateTrainingPage is a StatefulWidget that
/// allows users to create a new training session.
class CreateTrainingPage extends StatefulWidget {
  /// Creates a CreateTrainingPage widget.
  const CreateTrainingPage({super.key, this.selectedGymnast});

  /// Selected gymnast data.
  final Map<String, dynamic>? selectedGymnast;

  @override
  State<CreateTrainingPage> createState() => _CreateTrainingPageState();
}

class _CreateTrainingPageState extends State<CreateTrainingPage> {
  final _formKey = GlobalKey<FormState>();
  final _exercisesController = TextEditingController();
  DateTime? _selectedDate;

  String? _selectedGymnastId;
  String? _selectedGymnastUsername;
  late String _currentUserId;
  String? _currentUserRole;

  final TrainingService _trainingService = TrainingService();

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    _currentUserId = await AuthStorage.getUserId();
    final token = await AuthStorage.getToken();
    final decoded = AuthStorage.decodeToken(token);
    final role = (decoded['role'] as String).toLowerCase();
    setState(() {
      _currentUserRole = role;
      if (_currentUserRole == 'coach') {
        if (widget.selectedGymnast != null) {
          _selectedGymnastId = widget.selectedGymnast!['userId'].toString();
          _selectedGymnastUsername =
              widget.selectedGymnast!['username'].toString();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.push('/select-gymnast');
          });
        }
      }
    });
  }

  Future<void> _submitTraining() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }

    final exercises =
        _exercisesController.text.split(',').map((e) => e.trim()).toList();
    final userId =
        _currentUserRole == 'coach' ? _selectedGymnastId! : _currentUserId;
    final coachId = _currentUserRole == 'coach' ? _currentUserId : null;

    await _trainingService.createTraining(
      userId: userId,
      coachId: coachId,
      exercises: exercises,
      date: _selectedDate!,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Training created successfully!')),
    );

    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _exercisesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserRole == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final dateText = _selectedDate == null
        ? 'No date chosen'
        : 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}';
    return Scaffold(
      backgroundColor: BrandColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: BrandColors.backgroundColor,
        title: const Text('Create Training'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_currentUserRole == 'coach')
                Text(
                  'Creating training for: ${_selectedGymnastUsername ?? _selectedGymnastId}',
                ),
              TextFormField(
                controller: _exercisesController,
                decoration: const InputDecoration(
                  labelText: 'Exercises (comma separated)',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter exercises' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text(dateText)),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitTraining,
                child: const Text('Create Training'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
