import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../../data/models/poi_model.dart';

/// Service for calculating distance and estimated travel time between locations.
class DistanceService {
  /// Calculate distance in kilometers between two coordinates using Haversine formula.
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Calculate distance from current position to POI.
  Future<double?> distanceToPoi(PoiModel poi,
      {Position? currentPosition}) async {
    Position? position = currentPosition;

    if (position == null) {
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
      } catch (_) {
        return null;
      }
    }

    return calculateDistance(
      lat1: position.latitude,
      lon1: position.longitude,
      lat2: poi.latitude,
      lon2: poi.longitude,
    );
  }

  /// Estimate travel time based on distance and average speed.
  Duration estimateTravelTime({
    required double distanceKm,
    double averageSpeedKmh = 60.0, // Default highway speed
  }) {
    final hours = distanceKm / averageSpeedKmh;
    return Duration(minutes: (hours * 60).round());
  }

  /// Calculate both distance and travel time for a POI.
  Future<PoiDistanceInfo?> getPoiDistanceInfo(
    PoiModel poi, {
    Position? currentPosition,
    double averageSpeedKmh = 60.0,
  }) async {
    final distance = await distanceToPoi(poi, currentPosition: currentPosition);
    if (distance == null) return null;

    final travelTime = estimateTravelTime(
      distanceKm: distance,
      averageSpeedKmh: averageSpeedKmh,
    );

    return PoiDistanceInfo(
      distance: distance,
      travelTime: travelTime,
    );
  }

  /// Calculate distance info for multiple POIs efficiently.
  Future<Map<String, PoiDistanceInfo>> getMultiplePoiDistances(
    List<PoiModel> pois, {
    Position? currentPosition,
    double averageSpeedKmh = 60.0,
  }) async {
    Position? position = currentPosition;

    if (position == null) {
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        );
      } catch (_) {
        return {};
      }
    }

    final results = <String, PoiDistanceInfo>{};

    for (final poi in pois) {
      final distance = calculateDistance(
        lat1: position.latitude,
        lon1: position.longitude,
        lat2: poi.latitude,
        lon2: poi.longitude,
      );

      final travelTime = estimateTravelTime(
        distanceKm: distance,
        averageSpeedKmh: averageSpeedKmh,
      );

      results[poi.id] = PoiDistanceInfo(
        distance: distance,
        travelTime: travelTime,
      );
    }

    return results;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}

/// Container for POI distance and travel time information.
class PoiDistanceInfo {
  const PoiDistanceInfo({
    required this.distance,
    required this.travelTime,
  });

  final double distance; // km
  final Duration travelTime;

  String get distanceFormatted => '${distance.toStringAsFixed(1)} km';

  String get travelTimeFormatted {
    if (travelTime.inHours > 0) {
      final hours = travelTime.inHours;
      final minutes = travelTime.inMinutes.remainder(60);
      return '${hours}h ${minutes}m';
    }
    return '${travelTime.inMinutes} min';
  }
}
