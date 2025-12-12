import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/glass_bottom_nav.dart';
import 'features/explore/explore_screen.dart';
import 'features/home/premium_home_screen.dart';
import 'features/map/map_screen.dart';
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
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  final _screens = const [
    PremiumHomeScreen(),
    MapScreenEntry(),
    ExploreScreenEntry(),
    ProfileScreenEntry(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_index],
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _index,
        onTap: (value) => setState(() => _index = value),
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
