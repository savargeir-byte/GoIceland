import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/animations/micro_animations.dart';
import '../../core/services/saved_place_service.dart';

/// Saved places screen showing user's bookmarked locations.
class SavedPlacesScreen extends StatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  late SavedPlaceService _service;
  User? user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    try {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }
      user = auth.currentUser;
      if (user != null) {
        _service = SavedPlaceService(uid: user!.uid);
      }
    } catch (e) {
      debugPrint('Auth error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDelete(String poiId, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fjarlægja stað'),
        content: Text('Ertu viss um að þú viljir fjarlægja "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hætta við'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Fjarlægja'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.removePlace(poiId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name fjarlægður'),
              action: SnackBarAction(
                label: 'Afturkalla',
                onPressed: () async {
                  // TODO: Implement undo functionality
                },
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Villa: Gat ekki fjarlægt stað')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vistaðir staðir')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vistaðir staðir')),
        body: const Center(
          child: Text('Vinsamlegast skráðu þig inn til að vista staði'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vistaðir staðir'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              // TODO: Add sort options
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.streamSavedPlaces(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Villa: ${snapshot.error}'),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const _EmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final place = _SavedPlace(
                id: doc.id,
                name: data['name'] as String? ?? 'Unknown',
                location: data['location'] as String? ?? '',
                imageUrl: data['image_url'] as String? ??
                    'assets/images/placeholder.jpg',
                category: data['category'] as String? ?? 'Almennt',
              );

              return SlideInAnimation(
                delay: Duration(milliseconds: 100 * index),
                offset: const Offset(0, 20),
                child: _SavedPlaceCard(
                  place: place,
                  onDelete: () => _handleDelete(place.id, place.name),
                  onMapTap: () {
                    // TODO: Navigate to map with this location
                    final lat = data['latitude'] as double?;
                    final lng = data['longitude'] as double?;
                    if (lat != null && lng != null) {
                      // Navigate to map
                    }
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

class _SavedPlace {
  const _SavedPlace({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.category,
  });

  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final String category;
}

class _SavedPlaceCard extends StatelessWidget {
  const _SavedPlaceCard({
    required this.place,
    required this.onDelete,
    this.onMapTap,
  });

  final _SavedPlace place;
  final VoidCallback onDelete;
  final VoidCallback? onMapTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to place details or show on map
        },
        child: Row(
          children: [
            // Image thumbnail
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: Image.asset(
                place.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.place, size: 40);
                },
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place.location,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        place.category,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.map_outlined),
                  onPressed: onMapTap ??
                      () {
                        // TODO: Show on map
                      },
                  tooltip: 'Sjá á korti',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  tooltip: 'Fjarlægja',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Engir vistaðir staðir',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Vistaðu staði sem þú vilt heimsækja síðar með því að ýta á bókamerkjatáknið.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.explore),
              label: const Text('Skoða staði'),
            ),
          ],
        ),
      ),
    );
  }
}
