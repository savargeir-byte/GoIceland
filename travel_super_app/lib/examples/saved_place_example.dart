import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/saved_place_service.dart';
import '../../core/widgets/premium_place_card.dart';
import '../../data/models/poi_model.dart';

/// Example of how to use SavedPlaceService with PremiumPlaceCard.
///
/// This shows:
/// 1. How to check if a place is saved
/// 2. How to toggle save/unsave
/// 3. How to integrate with PremiumPlaceCard
class SavedPlaceExample extends ConsumerStatefulWidget {
  const SavedPlaceExample({super.key});

  @override
  ConsumerState<SavedPlaceExample> createState() => _SavedPlaceExampleState();
}

class _SavedPlaceExampleState extends ConsumerState<SavedPlaceExample> {
  SavedPlaceService? _service;
  final Map<String, bool> _savedStatus = {};

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    final user = auth.currentUser;
    if (user != null) {
      _service = SavedPlaceService(uid: user.uid);
    }
  }

  /// Check if a POI is saved.
  Future<bool> _checkIfSaved(String poiId) async {
    if (_savedStatus.containsKey(poiId)) {
      return _savedStatus[poiId]!;
    }
    if (_service != null) {
      final isSaved = await _service!.isSaved(poiId);
      setState(() => _savedStatus[poiId] = isSaved);
      return isSaved;
    }
    return false;
  }

  /// Toggle save/unsave for a POI.
  Future<void> _toggleSave(PoiModel poi) async {
    if (_service == null) return;

    try {
      await _service!.toggleSave(
        poiId: poi.id,
        name: poi.name,
        location: poi.description ?? '',
        imageUrl: poi.image,
        category: poi.category?.name,
        latitude: poi.latitude,
        longitude: poi.longitude,
      );

      // Update local state
      setState(() {
        _savedStatus[poi.id] = !(_savedStatus[poi.id] ?? false);
      });

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _savedStatus[poi.id]!
                  ? '${poi.name} vistaður'
                  : '${poi.name} fjarlægður',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Villa: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Example POI
    final examplePoi = PoiModel(
      id: 'example_poi_1',
      name: 'Gullfoss',
      latitude: 64.3271,
      longitude: -20.1222,
      image: 'https://example.com/gullfoss.jpg',
      description: 'Íslenskt vatnsfoss',
      rating: 4.8,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Place Example')),
      body: Center(
        child: FutureBuilder<bool>(
          future: _checkIfSaved(examplePoi.id),
          builder: (context, snapshot) {
            final isSaved = snapshot.data ?? false;

            return PremiumPlaceCard(
              poi: examplePoi,
              isSaved: isSaved,
              onTap: () {
                // Handle card tap - navigate to details
              },
              onBookmarkTap: () => _toggleSave(examplePoi),
            );
          },
        ),
      ),
    );
  }
}
