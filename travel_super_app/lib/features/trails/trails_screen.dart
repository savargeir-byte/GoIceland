import 'package:flutter/material.dart';

import '../../data/api/trail_api.dart';
import '../../data/models/trail_model.dart';

class TrailsScreen extends StatefulWidget {
  final void Function(TrailModel)? onTrailSelected;
  
  const TrailsScreen({super.key, this.onTrailSelected});

  @override
  State<TrailsScreen> createState() => _TrailsScreenState();
}

class _TrailsScreenState extends State<TrailsScreen> {
  final _trailApi = TrailApi();
  late Future<List<TrailModel>> _trailsFuture;

  @override
  void initState() {
    super.initState();
    _trailsFuture = _trailApi.fetchAllTrails();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          AppBar(
            title: Text(
              'Gönguleiðir',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            elevation: 0,
          ),
          Expanded(
            child: FutureBuilder<List<TrailModel>>(
              future: _trailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Villa: ${snapshot.error}'));
                }

                final trails = snapshot.data ?? [];

                if (trails.isEmpty) {
                  return const Center(child: Text('Engar gönguleiðir fundust'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trails.length,
                  itemBuilder: (context, index) {
                    final trail = trails[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        onTap: () => _showTrailOnMap(trail),
                        title: Text(
                          trail.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${trail.lengthKm.toStringAsFixed(1)} km • ${trail.formattedDuration} • ${trail.elevationGain}m',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(trail.difficulty),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _getDifficultyColor(trail.difficulty).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            trail.difficulty.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTrailOnMap(TrailModel trail) {
    widget.onTrailSelected?.call(trail);
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
