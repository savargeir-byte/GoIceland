import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/crystal_bottom_nav.dart';
import 'data/models/trail_model.dart';
import 'features/explore/explore_screen.dart';
import 'features/home/crystal_home_screen.dart';
import 'features/map/map_screen.dart';
import 'features/trails/trails_screen.dart';
import 'features/user/profile_screen.dart';

class TravelSuperApp extends StatelessWidget {
  const TravelSuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'GO ICELAND',
        theme: appTheme,
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        home: AppShell(key: appShellKey),
      ),
    );
  }
}

// Global key for accessing AppShell state
final GlobalKey<_AppShellState> appShellKey = GlobalKey<_AppShellState>();

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  TrailModel? _currentTrail;

  void switchToTab(int tabIndex) {
    setState(() {
      _index = tabIndex;
      if (tabIndex != 1) {
        _currentTrail = null;
      }
    });
  }

  void switchToMapWithTrail(TrailModel trail) {
    setState(() {
      _currentTrail = trail;
      _index = 1; // Map tab
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const CrystalHomeScreen(),
      MapScreen(trail: _currentTrail),
      TrailsScreen(onTrailSelected: switchToMapWithTrail),
      const ExploreScreenEntry(),
      const ProfileScreenEntry(),
    ];

    return Scaffold(
      extendBody: true,
      body: screens[_index],
      bottomNavigationBar: CrystalBottomNav(
        currentIndex: _index,
        onTap: (value) {
          setState(() {
            _index = value;
            // Clear trail when switching away from map
            if (value != 1) {
              _currentTrail = null;
            }
          });
        },
      ),
    );
  }
}

class MapScreenEntry extends StatelessWidget {
  const MapScreenEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return const MapScreen();
  }
}

class ExploreScreenEntry extends StatelessWidget {
  const ExploreScreenEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExploreScreen();
  }
}

class ProfileScreenEntry extends StatelessWidget {
  const ProfileScreenEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileScreen();
  }
}
