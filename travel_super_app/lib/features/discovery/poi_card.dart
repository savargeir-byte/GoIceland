import 'package:flutter/material.dart';

import '../../data/models/poi_model.dart';

class PoiCard extends StatelessWidget {
  const PoiCard({super.key, required this.poi});

  final PoiModel poi;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              poi.image ?? '',
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          ListTile(
            title: Text(poi.name),
            subtitle: Text('${poi.type} • ${poi.open ?? 'All day'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                Text('${poi.rating ?? 'New'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
