import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/admin_trail.dart';
import '../services/admin_trail_service.dart';
import 'trail_edit_screen.dart';

/// 🥾 Trails List Screen - Browse and manage hiking trails
class TrailsListScreen extends StatefulWidget {
  const TrailsListScreen({super.key});

  @override
  State<TrailsListScreen> createState() => _TrailsListScreenState();
}

class _TrailsListScreenState extends State<TrailsListScreen> {
  final _trailService = AdminTrailService();
  final _searchController = TextEditingController();

  String? _selectedDifficulty;
  String _searchQuery = '';

  final List<String> _difficulties = [
    'All',
    'Easy',
    'Moderate',
    'Hard',
    'Expert',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Trails'),
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search trails...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
                const SizedBox(height: 12),
                // Difficulty filter chips
                Wrap(
                  spacing: 8,
                  children: _difficulties.map((difficulty) {
                    final isSelected = difficulty == 'All'
                        ? _selectedDifficulty == null
                        : _selectedDifficulty == difficulty.toLowerCase();

                    return ChoiceChip(
                      label: Text(difficulty),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (difficulty == 'All') {
                            _selectedDifficulty = null;
                          } else {
                            _selectedDifficulty =
                                selected ? difficulty.toLowerCase() : null;
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Trails list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _trailService.getTrails(
                difficulty: _selectedDifficulty,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var trails = snapshot.data!.docs
                    .map((doc) => AdminTrail.fromFirestore(doc))
                    .toList();

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  trails = trails
                      .where((trail) =>
                          trail.name.toLowerCase().contains(_searchQuery) ||
                          (trail.region?.toLowerCase().contains(_searchQuery) ??
                              false))
                      .toList();
                }

                if (trails.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hiking,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No trails found matching "$_searchQuery"'
                              : 'No trails found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trails.length,
                  itemBuilder: (context, index) {
                    final trail = trails[index];
                    return _TrailCard(
                      trail: trail,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TrailEditScreen(trailId: trail.id),
                          ),
                        );
                      },
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
}

class _TrailCard extends StatelessWidget {
  final AdminTrail trail;
  final VoidCallback onTap;

  const _TrailCard({
    required this.trail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Trail image
            Container(
              width: 120,
              height: 100,
              color: Colors.grey.shade200,
              child: trail.coverImage != null
                  ? Image.network(
                      trail.coverImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.hiking, size: 40),
                    )
                  : const Icon(Icons.hiking, size: 40),
            ),
            // Trail info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trail.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (trail.difficulty != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            trail.difficultyEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            trail.difficulty!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (trail.region != null)
                      Text(
                        trail.region!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.straighten,
                          label: trail.displayLength,
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.schedule,
                          label: trail.displayDuration,
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          icon: Icons.terrain,
                          label: trail.displayElevation,
                        ),
                        if (trail.hasCamping == true) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.deck, size: 16, color: Colors.green),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blue.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
