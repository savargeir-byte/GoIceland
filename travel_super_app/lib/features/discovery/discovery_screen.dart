import 'package:flutter/material.dart';

import '../../data/api/poi_api.dart';
import '../../data/models/poi_model.dart';
import 'poi_card.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final _api = PoiApi();
  late Future<List<PoiModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchFeatured();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Places Near You')),
      body: FutureBuilder<List<PoiModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(
                child: Text('Add POIs in Firestore to see them here.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, index) => PoiCard(poi: data[index]),
            itemCount: data.length,
          );
        },
      ),
    );
  }
}
