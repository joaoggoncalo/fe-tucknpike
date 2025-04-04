// File: lib/views/profile_page.dart
import 'package:fe_tucknpike/constants/brand_colors.dart';
import 'package:fe_tucknpike/models/trainings.dart';
import 'package:fe_tucknpike/services/auth_service.dart';
import 'package:fe_tucknpike/services/coach_service.dart';
import 'package:fe_tucknpike/services/gymnast_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A page that displays the user's profile
/// information and training statistics.
class ProfilePage extends StatefulWidget {
  /// Creates a [ProfilePage] widget.
  const ProfilePage({super.key});
  @override
  ProfilePageState createState() => ProfilePageState();
}

/// The state for the [ProfilePage] widget.
class ProfilePageState extends State<ProfilePage> {
  String _username = '';
  String _role = '';
  List<Training> _trainings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final authService = AuthService();
    _role = authService.userRole!;
    _username = authService.username!;
    try {
      if (_role == 'coach') {
        _trainings = await CoachService().getAthletesTrainings();
      } else {
        _trainings = await GymnastService().getTrainings();
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('Error loading profile trainings: $e');
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Map<String, int> _calculateStatistics() {
    var scheduled = 0;
    var completed = 0;
    var missed = 0;
    for (final t in _trainings) {
      final status = t.status.toLowerCase();
      if (status == 'scheduled') scheduled++;
      if (status == 'completed') completed++;
      if (status == 'missed') missed++;
    }
    return {
      'Total': _trainings.length,
      'Scheduled': scheduled,
      'Completed': completed,
      'Missed': missed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStatistics();

    return Scaffold(
      backgroundColor: BrandColors.backgroundColor,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: BrandColors.accentColor),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: BrandColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        _role.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: BrandColors.darkAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Training Statistics',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: BrandColors.cardColor,
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: stats.entries.map((entry) {
                            return Column(
                              children: [
                                Text(
                                  '${entry.value}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: BrandColors.accentColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: BrandColors.darkAccent,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Trainings',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: BrandColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: _trainings.take(10).map((training) {
                        final formattedDate =
                            '${training.date.month}/${training.date.day}/${training.date.year}';
                        return Card(
                          color: BrandColors.cardColor,
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Text(
                              '🤸',
                              style: TextStyle(
                                fontSize: 32,
                                color: BrandColors.accentColor,
                              ),
                            ),
                            title: Text(
                              'Training on $formattedDate',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: BrandColors.primaryColor,
                              ),
                            ),
                            subtitle: _role == 'coach'
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Status: ${training.status}',
                                        style: const TextStyle(
                                          color: BrandColors.darkAccent,
                                        ),
                                      ),
                                      Text(
                                        'Gymnast: ${training.gymnastUsername ?? "Unknown"}',
                                        style: const TextStyle(
                                          color: BrandColors.darkAccent,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Status: ${training.status}',
                                    style: const TextStyle(
                                      color: BrandColors.darkAccent,
                                    ),
                                  ),
                            onTap: () {
                              context.go(
                                '/trainings/${training.trainingId}?from=profile',
                                extra: training,
                              );
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
