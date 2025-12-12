import 'package:flutter/material.dart';

import '../../data/models/poi_model.dart';

class PinDetailsSheet extends StatelessWidget {
  const PinDetailsSheet({super.key, required this.poi});

  final PoiModel poi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 6,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Text(poi.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('${poi.type} • ${poi.open ?? 'Open hours TBD'}'),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 20),
              const SizedBox(width: 4),
              Text((poi.rating ?? 0).toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.directions),
                  label: const Text('Navigate'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
