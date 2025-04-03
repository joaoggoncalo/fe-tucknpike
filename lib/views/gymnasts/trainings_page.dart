// File: lib/views/gymnasts/trainings_page.dart
import 'package:fe_tucknpike/components/trainings_list.dart';
import 'package:fe_tucknpike/models/trainings.dart';
import 'package:fe_tucknpike/services/gymnast_service.dart';
import 'package:fe_tucknpike/stores/auth_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// This widget displays a calendar view of trainings for the current month.
class TrainingsPage extends StatefulWidget {
  /// Creates a [TrainingsPage] widget.
  const TrainingsPage({super.key});

  @override
  TrainingsPageState createState() => TrainingsPageState();
}

/// This class manages the state of the [TrainingsPage] widget.
class TrainingsPageState extends State<TrainingsPage> {
  DateTime _displayedMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  final GymnastService _gymnastService = GymnastService();
  List<Training> _trainings = [];
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadTrainings();
  }

  Future<void> _loadTrainings() async {
    try {
      _userId = await AuthStorage.getUserId();
      if (_userId != null) {
        final trainings = await _gymnastService.getTrainings();
        setState(() {
          _trainings = trainings;
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error fetching trainings: $e');
      }
    }
  }

  String _getTrainingStatusForDay(int day) {
    for (final training in _trainings) {
      if (training.date.year == _displayedMonth.year &&
          training.date.month == _displayedMonth.month &&
          training.date.day == day) {
        return training.status.toLowerCase();
      }
    }
    return '';
  }

  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  List<Widget> _buildCalendarDays() {
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final status = _getTrainingStatusForDay(day);
      Color borderColor = Colors.grey;
      var circlesCount = 0;
      var circleColor = Colors.transparent;

      if (status == 'scheduled') {
        borderColor = Colors.blue;
        circlesCount = 1;
        circleColor = Colors.blue;
      } else if (status == 'completed') {
        borderColor = Colors.green;
        circlesCount = 3;
        circleColor = Colors.green;
      } else if (status == 'missed') {
        borderColor = Colors.red;
        circlesCount = 2;
        circleColor = Colors.red;
      }
      final borderWidth = status.isNotEmpty ? 4.0 : 1.0;

      Widget buildStatusCircles() {
        if (circlesCount == 0) return const SizedBox.shrink();
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(circlesCount, (_) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor,
              ),
            );
          }),
        );
      }

      return Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day'),
            const SizedBox(height: 4),
            buildStatusCircles(),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthStr = DateFormat('MMMM yyyy').format(_displayedMonth);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: _goToPreviousMonth,
                  icon: const Text('<', style: TextStyle(fontSize: 20)),
                ),
                Expanded(
                  child: Center(
                    child: Text(monthStr, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                IconButton(
                  onPressed: _goToNextMonth,
                  icon: const Text('>', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _buildCalendarDays(),
            ),
            const SizedBox(height: 20),
            TrainingsList(trainings: _trainings),
          ],
        ),
      ),
    );
  }
}
