import 'package:fe_tucknpike/services/coach_service.dart';
import 'package:flutter/material.dart';

/// The page that displays the gymnasts for a coach and allows adding gymnasts.
class GymnastsPage extends StatefulWidget {
  /// GymnastsPage constructor.
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
      body: FutureBuilder<Map<String, List<dynamic>>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Connected gymnasts.
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Connected Gymnasts',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (connected.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('No connected gymnasts.'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: connected.length,
                    itemBuilder: (context, index) {
                      final gymnastId = connected[index].toString();
                      final gymnastData = gymnastMap[gymnastId];
                      String title;
                      String? subtitle;
                      if (gymnastData != null) {
                        title = gymnastData['username'].toString();
                        subtitle = 'ID: ${gymnastData['userId']}';
                      } else {
                        title = gymnastId;
                        subtitle = null;
                      }
                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(title),
                          subtitle: subtitle != null ? Text(subtitle) : null,
                        ),
                      );
                    },
                  ),
                // Section: Available gymnasts.
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Available Gymnasts',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (available.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('No available gymnasts to add.'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: available.length,
                    itemBuilder: (context, index) {
                      final gymnast = available[index] as Map<String, dynamic>;
                      return ListTile(
                        title: Text(gymnast['username'].toString()),
                        subtitle: Text('ID: ${gymnast['userId']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            await _addGymnast(gymnast['userId'].toString());
                          },
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
