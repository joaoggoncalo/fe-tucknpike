// File: lib/views/coaches/gymnasts_page.dart
import 'package:fe_tucknpike/constants/brand_colors.dart';
import 'package:fe_tucknpike/services/coach_service.dart';
import 'package:flutter/material.dart';

/// A page that displays a list of gymnasts connected to the coach
class GymnastsPage extends StatefulWidget {
  /// Creates a [GymnastsPage] widget.
  const GymnastsPage({super.key});

  @override
  State<GymnastsPage> createState() => _GymnastsPageState();
}

class _GymnastsPageState extends State<GymnastsPage> {
  final CoachService _coachService = CoachService();
  late Future<Map<String, List<dynamic>>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<Map<String, List<dynamic>>> _loadData() async {
    final connected = await _coachService.getGymnasts();
    final all = await _coachService.getAllGymnasts();
    return {'connected': connected, 'all': all};
  }

  Future<void> _addGymnast(String gymnastUserId) async {
    await _coachService.addGymnast(gymnastUserId);
    setState(() {
      _dataFuture = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.backgroundColor,
      // The shell already provides the app bar.
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: BrandColors.accentColor),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: BrandColors.darkAccent),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'No data available.',
                style: TextStyle(color: BrandColors.darkAccent),
              ),
            );
          }

          final connected = snapshot.data!['connected']!;
          final all = snapshot.data!['all']!;
          final gymnastMap = {
            for (final gymnast in all.cast<Map<String, dynamic>>())
              gymnast['userId'].toString(): gymnast,
          };
          final connectedIds = connected.map((g) => g.toString()).toSet();
          final available = all
              .where(
                (gymnast) => !connectedIds.contains(
                  (gymnast as Map<String, dynamic>)['userId'].toString(),
                ),
              )
              .toList();

          return CustomScrollView(
            slivers: [
              // Connected Gymnasts Section
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Connected Gymnasts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.primaryColor,
                    ),
                  ),
                ),
              ),
              if (connected.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'No connected gymnasts.',
                        style: TextStyle(color: BrandColors.darkAccent),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final gymnastId = connected[index].toString();
                      final gymnastData = gymnastMap[gymnastId];
                      final title = gymnastData != null
                          ? gymnastData['username'].toString()
                          : gymnastId;
                      final subtitle = gymnastData != null
                          ? 'ID: ${gymnastData['userId']}'
                          : null;
                      return Card(
                        color: BrandColors.cardColor,
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: BrandColors.accentColor,
                            size: 32,
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                              color: BrandColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: subtitle != null
                              ? Text(
                                  subtitle,
                                  style: const TextStyle(
                                    color: BrandColors.darkAccent,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                    childCount: connected.length,
                  ),
                ),
              // Available Gymnasts Section
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    'Available Gymnasts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.primaryColor,
                    ),
                  ),
                ),
              ),
              if (available.isEmpty)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'No available gymnasts to add.',
                        style: TextStyle(color: BrandColors.darkAccent),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final gymnast = available[index] as Map<String, dynamic>;
                      return Card(
                        color: BrandColors.cardColor,
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: ListTile(
                          leading: const Icon(
                            Icons.add_circle_outline,
                            color: BrandColors.accentColor,
                            size: 32,
                          ),
                          title: Text(
                            gymnast['username'].toString(),
                            style: const TextStyle(
                              color: BrandColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            'ID: ${gymnast['userId']}',
                            style:
                                const TextStyle(color: BrandColors.darkAccent),
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BrandColors.accentColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              await _addGymnast(gymnast['userId'].toString());
                            },
                            child: const Text(
                              'Add',
                              style:
                                  TextStyle(color: BrandColors.backgroundColor),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: available.length,
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 16),
              ),
            ],
          );
        },
      ),
    );
  }
}
