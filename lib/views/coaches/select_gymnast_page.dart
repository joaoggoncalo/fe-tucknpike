import 'package:fe_tucknpike/constants/brand_colors.dart';
import 'package:fe_tucknpike/services/coach_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A page that allows coaches to select a gymnast for training.
class SelectGymnastPage extends StatefulWidget {
  /// Creates a [SelectGymnastPage] widget.
  const SelectGymnastPage({super.key});

  @override
  State<SelectGymnastPage> createState() => _SelectGymnastPageState();
}

class _SelectGymnastPageState extends State<SelectGymnastPage> {
  final CoachService _coachService = CoachService();
  late Future<List<Map<String, dynamic>>> _gymnastsFuture;

  @override
  void initState() {
    super.initState();
    _gymnastsFuture = _loadGymnasts();
  }

  // dart
  Future<List<Map<String, dynamic>>> _loadGymnasts() async {
    final connectedIds =
        (await _coachService.getGymnasts()).map((id) => id.toString()).toSet();
    final allGymnasts = await _coachService.getAllGymnasts();
    final filteredGymnasts = allGymnasts
        .cast<Map<String, dynamic>>()
        .where((gymnast) => connectedIds.contains(gymnast['userId'].toString()))
        .toList();
    return filteredGymnasts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: BrandColors.backgroundColor,
        title: const Text('Select Gymnast'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/gymnasts'),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _gymnastsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final gymnasts = snapshot.data!;
          return ListView.builder(
            itemCount: gymnasts.length,
            itemBuilder: (context, index) {
              final gymnast = gymnasts[index];
              return Card(
                color: BrandColors.cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.person,
                      color: BrandColors.accentColor, size: 32),
                  title: Text(
                    gymnast['username'].toString(),
                    style: const TextStyle(
                      color: BrandColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('ID: ${gymnast['userId']}'),
                  onTap: () {
                    context.push('/create-training', extra: gymnast);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
