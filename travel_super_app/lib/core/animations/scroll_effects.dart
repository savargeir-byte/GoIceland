import 'package:flutter/material.dart';

/// Custom scroll physics with enhanced bounce and spring effects.
class PremiumScrollPhysics extends BouncingScrollPhysics {
  const PremiumScrollPhysics({super.parent});

  @override
  PremiumScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PremiumScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 100.0;

  @override
  double get maxFlingVelocity => 3000.0;

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Apply subtle resistance at edges
    if (offset.abs() < 0.01) return offset;

    final overscroll = position.pixels - position.minScrollExtent;
    if (overscroll < 0) {
      // Gentle resistance at top
      return offset * 0.7;
    }

    final overscrollBottom = position.pixels - position.maxScrollExtent;
    if (overscrollBottom > 0) {
      // Gentle resistance at bottom
      return offset * 0.7;
    }

    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    final tolerance = toleranceFor(position);

    if (velocity.abs() >= tolerance.velocity || position.outOfRange) {
      return BouncingScrollSimulation(
        spring: spring,
        position: position.pixels,
        velocity: velocity,
        leadingExtent: position.minScrollExtent,
        trailingExtent: position.maxScrollExtent,
        tolerance: tolerance,
      );
    }
    return null;
  }
}

/// Parallax scroll delegate for custom parallax effects in CustomScrollView.
class ParallaxScrollDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double _minExtent;
  final double _maxExtent;
  final double parallaxFactor;

  ParallaxScrollDelegate({
    required this.child,
    required double minExtent,
    required double maxExtent,
    this.parallaxFactor = 0.5,
  })  : _minExtent = minExtent,
        _maxExtent = maxExtent;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final offset = shrinkOffset * parallaxFactor;
    return Transform.translate(
      offset: Offset(0, offset),
      child: child,
    );
  }

  @override
  double get maxExtent => _maxExtent;

  @override
  double get minExtent => _minExtent;

  @override
  bool shouldRebuild(covariant ParallaxScrollDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate._minExtent != _minExtent ||
        oldDelegate._maxExtent != _maxExtent ||
        oldDelegate.parallaxFactor != parallaxFactor;
  }
}
