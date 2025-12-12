import 'package:flutter/material.dart';

import '../animations/page_transitions.dart';

/// Premium navigation helper with animated transitions.
class PremiumNavigation {
  /// Navigate with fade transition.
  static Future<T?> fadeToPage<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      FadePageRoute(page: page),
    );
  }

  /// Navigate with slide-up transition (for modals/sheets).
  static Future<T?> slideUpToPage<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      SlideUpPageRoute(page: page),
    );
  }

  /// Navigate with scale transition (for detail views).
  static Future<T?> scaleToPage<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      ScalePageRoute(page: page),
    );
  }

  /// Navigate with shared axis transition (default premium navigation).
  static Future<T?> sharedAxisToPage<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).push<T>(
      SharedAxisPageRoute(page: page),
    );
  }

  /// Push replacement with fade.
  static Future<T?> fadeReplacePage<T, TO>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(context).pushReplacement<T, TO>(
      FadePageRoute(page: page),
    );
  }

  /// Push and remove until with shared axis.
  static Future<T?> sharedAxisPushAndRemoveUntil<T>(
    BuildContext context,
    Widget page,
    bool Function(Route<dynamic>) predicate,
  ) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      SharedAxisPageRoute(page: page),
      predicate,
    );
  }
}

/// Extension methods for convenient navigation.
extension PremiumNavigationExtension on BuildContext {
  /// Navigate with fade transition.
  Future<T?> fadeTo<T>(Widget page) {
    return PremiumNavigation.fadeToPage<T>(this, page);
  }

  /// Navigate with slide-up transition.
  Future<T?> slideUpTo<T>(Widget page) {
    return PremiumNavigation.slideUpToPage<T>(this, page);
  }

  /// Navigate with scale transition.
  Future<T?> scaleTo<T>(Widget page) {
    return PremiumNavigation.scaleToPage<T>(this, page);
  }

  /// Navigate with shared axis transition.
  Future<T?> sharedAxisTo<T>(Widget page) {
    return PremiumNavigation.sharedAxisToPage<T>(this, page);
  }
}
