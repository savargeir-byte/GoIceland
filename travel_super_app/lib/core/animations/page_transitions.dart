import 'package:flutter/material.dart';

/// Fade page transition for smooth screen changes.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

/// Slide from bottom page transition with fade.
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  SlideUpPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 350),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.1);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            final offsetAnimation = animation.drive(tween);
            final fadeAnimation = animation.drive(
              Tween<double>(begin: 0.0, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeOut)),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Scale page transition with fade for modal-like navigation.
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  ScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scaleAnimation = animation.drive(
              Tween<double>(begin: 0.85, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            );
            final fadeAnimation = animation.drive(
              Tween<double>(begin: 0.0, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeOut)),
            );

            return ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Shared axis page transition (Material Design pattern).
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  SharedAxisPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Outgoing page slides left and fades
            if (secondaryAnimation.status != AnimationStatus.dismissed) {
              final offsetAnimation = secondaryAnimation.drive(
                Tween<Offset>(begin: Offset.zero, end: const Offset(-0.1, 0))
                    .chain(CurveTween(curve: Curves.easeInCubic)),
              );
              final fadeAnimation = secondaryAnimation.drive(
                Tween<double>(begin: 1.0, end: 0.0)
                    .chain(CurveTween(curve: Curves.easeIn)),
              );

              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: child,
                ),
              );
            }

            // Incoming page slides from right and fades in
            final offsetAnimation = animation.drive(
              Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            );
            final fadeAnimation = animation.drive(
              Tween<double>(begin: 0.0, end: 1.0)
                  .chain(CurveTween(curve: Curves.easeOut)),
            );

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}
