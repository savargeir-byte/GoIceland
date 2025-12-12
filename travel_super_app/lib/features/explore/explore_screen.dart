import 'package:flutter/material.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const _sections = [
    _ExploreItem(
      title: 'Photo Spots',
      subtitle: 'Curated scenic frames by Ellie',
      icon: Icons.camera_alt_outlined,
    ),
    _ExploreItem(
      title: 'Food Radar',
      subtitle: 'Veg-friendly tracker powered by Ellie',
      icon: Icons.restaurant,
    ),
    _ExploreItem(
      title: 'Hidden Gems',
      subtitle: 'Crowdsourced by the Firestore community',
      icon: Icons.park,
    ),
    _ExploreItem(
      title: 'Ellie • AI trip concierge',
      subtitle: 'Ask for hyper-local plans & Mapbox routes',
      icon: Icons.auto_awesome,
      highlight: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, index) => _ExploreSection(item: _sections[index]),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: _sections.length,
      ),
    );
  }
}

class _ExploreItem {
  const _ExploreItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.highlight = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool highlight;
}

class _ExploreSection extends StatelessWidget {
  const _ExploreSection({required this.item});

  final _ExploreItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: item.highlight
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
              offset: Offset(0, 8), blurRadius: 20, color: Colors.black12),
        ],
      ),
      child: Row(
        children: [
          Icon(item.icon, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(item.subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
