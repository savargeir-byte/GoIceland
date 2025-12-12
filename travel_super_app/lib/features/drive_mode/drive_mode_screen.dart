import 'package:flutter/material.dart';

import '../../core/services/road_service.dart';

class DriveModeScreen extends StatefulWidget {
  const DriveModeScreen({super.key});

  @override
  State<DriveModeScreen> createState() => _DriveModeScreenState();
}

class _DriveModeScreenState extends State<DriveModeScreen> {
  final _service = RoadService();
  late Future<List<RoadCondition>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchLiveStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drive Mode')),
      body: FutureBuilder<List<RoadCondition>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? const [];
          if (data.isEmpty) {
            return const Center(
                child: Text(
                    'Add Vegagerðin feed url in .env to see road statuses.'));
          }
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, index) {
              final item = data[index];
              return ListTile(
                leading: const Icon(Icons.alt_route),
                title: Text(item.segment),
                subtitle: Text(item.note ?? 'No alerts'),
                trailing: Text(item.status),
              );
            },
          );
        },
      ),
    );
  }
}
