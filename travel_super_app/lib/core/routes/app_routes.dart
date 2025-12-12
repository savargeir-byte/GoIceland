import 'package:flutter/material.dart';

import '../../features/ai/ai_chat_assistant.dart';
import '../../features/discovery/discovery_screen.dart';
import '../../features/explore/explore_feed_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/saved_places_screen.dart';
import '../../features/surprise/surprise_me_page.dart';

class AppRoutes {
  static const home = '/home';
  static const onboarding = '/onboarding';
  static const map = '/map';
  static const discovery = '/discovery';
  static const aiAssistant = '/ai';
  static const surprise = '/surprise';
  static const savedPlaces = '/saved-places';
  static const exploreFeed = '/explore-feed';

  static Map<String, WidgetBuilder> get routes => {
        onboarding: (_) => const OnboardingScreen(),
        map: (_) => const MapScreen(),
        discovery: (_) => const DiscoveryScreen(),
        aiAssistant: (_) => const AIChatAssistant(),
        surprise: (_) => const SurpriseMePage(),
        savedPlaces: (_) => const SavedPlacesScreen(),
        exploreFeed: (_) => const ExploreFeedScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        return null;
    }
  }
}
