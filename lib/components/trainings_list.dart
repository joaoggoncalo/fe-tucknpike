import 'package:fe_tucknpike/models/trainings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// This widget displays a list of trainings.
class TrainingsList extends StatelessWidget {
  /// Creates a [TrainingsList] widget.
  const TrainingsList({
    required this.trainings,
    super.key,
    this.title = 'Upcoming Scheduled Trainings',
  });

  /// The list of trainings to display.
  final List<Training> trainings;

  /// The title of the list.
  final String title;

  @override
  Widget build(BuildContext context) {
    // Filter trainings for scheduled ones, sort by date, and limit to 5.
    final scheduledTrainings = trainings
        .where((t) => t.status.toLowerCase() == 'scheduled')
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    final displayedTrainings = scheduledTrainings.length > 5
        ? scheduledTrainings.sublist(0, 5)
        : scheduledTrainings;

    if (displayedTrainings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        // Use a ListView.builder with shrinkWrap.
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedTrainings.length,
          itemBuilder: (context, index) {
            final training = displayedTrainings[index];
            final formattedDate =
                DateFormat('MMM d, yyyy').format(training.date);
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Text(
                  '🤸',
                  style: TextStyle(fontSize: 24),
                ),
                title: Text('Training on $formattedDate'),
                subtitle: Text('Status: ${training.status}'),
              ),
            );
          },
        ),
      ],
    );
  }
}
