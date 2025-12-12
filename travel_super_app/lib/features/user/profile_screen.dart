import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prófíll')),
      body: ListView(
        children: [
          // User profile header
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ferðamaður',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'user@example.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: const Text('Vistaðir staðir'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.savedPlaces);
            },
          ),
          ListTile(
            leading: const Icon(Icons.explore),
            title: const Text('Explore Feed'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.exploreFeed);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Reikningur'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Stillingar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Skrá út', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
