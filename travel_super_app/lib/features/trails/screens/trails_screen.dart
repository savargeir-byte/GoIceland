import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/trail_detail_screen.dart';

/// 🥾 TRAILS SCREEN - Browse hiking trails
/// Simple list view with Firebase integration
class TrailsScreen extends StatefulWidget {
  const TrailsScreen({super.key});

  @override
  State<TrailsScreen> createState() => _TrailsScreenState();
}

class _TrailsScreenState extends State<TrailsScreen> {
  String? _selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Hiking Trails'),
          ),
          
          // Difficulty filters
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _difficultyChip('All', null),
                  _difficultyChip('Easy', 'easy', Colors.green),
                  _difficultyChip('Moderate', 'moderate', Colors.orange),
                  _difficultyChip('Challenging', 'challenging', Colors.red),
                  _difficultyChip('Expert', 'expert', Colors.purple),
                ],
              ),
            ),
          ),
          
          // Trails list from Firebase
          StreamBuilder<QuerySnapshot>(
            stream: _buildQuery().snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No trails found')),
                );
              }

              final docs = snapshot.data!.docs;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _buildTrailCard(data),
                    );
                  },
                  childCount: docs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('trails');
    
    if (_selectedDifficulty != null) {
      query = query.where('difficulty', isEqualTo: _selectedDifficulty);
    }
    
    return query.limit(100);
  }

  Widget _difficultyChip(String label, String? difficulty, [Color? color]) {
    final isSelected = _selectedDifficulty == difficulty;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedDifficulty = selected ? difficulty : null);
        },
        backgroundColor: Colors.white,
        selectedColor: color?.withOpacity(0.3) ?? Colors.blue.withOpacity(0.3),
      ),
    );
  }

  Widget _buildTrailCard(Map<String, dynamic> data) {
    final name = data['name'] ?? 'Unknown Trail';
    final difficulty = data['difficulty'] ?? '';
    final distance = data['distance_km'] as num?;
    final duration = data['duration_hours'] as num?;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrailDetailScreen(trail: data),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trail name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Stats row
              Wrap(
                spacing: 8,
                children: [
                  if (difficulty.isNotEmpty)
                    Chip(
                      label: Text(difficulty.toUpperCase()),
                      backgroundColor: _getDifficultyColor(difficulty).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _getDifficultyColor(difficulty),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (distance != null)
                    Chip(
                      label: Text('${distance.toStringAsFixed(1)} km'),
                      avatar: const Icon(Icons.straighten, size: 16),
                    ),
                  if (duration != null)
                    Chip(
                      label: Text('${duration.toStringAsFixed(1)} hrs'),
                      avatar: const Icon(Icons.access_time, size: 16),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'moderate':
        return Colors.orange;
      case 'challenging':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
