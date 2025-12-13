import 'package:flutter/material.dart';

import '../data/models/place.dart';
import '../data/repositories/places_repository.dart';

/// 🏔️ PlacesProvider - State management for places data
class PlacesProvider extends ChangeNotifier {
  final PlacesRepository _repository = PlacesRepository();

  List<Place> _places = [];
  List<Place> _featuredPlaces = [];
  String? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Place> get places => _places;
  List<Place> get featuredPlaces => _featuredPlaces;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get filtered places based on category and search
  List<Place> get filteredPlaces {
    var filtered = _places;

    // Filter by category
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filtered =
          filtered.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  /// Get stream of all places from Firebase
  Stream<List<Place>> get placesStream {
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      return _repository.getPlacesByCategory(_selectedCategory!);
    }
    return _repository.getAllPlaces();
  }

  /// Load featured places
  Future<void> loadFeaturedPlaces() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _featuredPlaces = await _repository.getFeaturedPlaces();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all places
  Future<void> loadPlaces() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await for (final places in _repository.getAllPlaces().take(1)) {
        _places = places;
        _isLoading = false;
        notifyListeners();
        break;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set selected category filter
  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Clear category filter
  void clearCategory() {
    _selectedCategory = null;
    notifyListeners();
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    notifyListeners();
  }

  /// Search places by query
  Future<void> searchPlaces(String query) async {
    try {
      _isLoading = true;
      _error = null;
      _searchQuery = query;
      notifyListeners();

      await for (final places in _repository.searchPlaces(query).take(1)) {
        _places = places;
        _isLoading = false;
        notifyListeners();
        break;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get nearby places
  Future<void> getNearbyPlaces(double lat, double lng, double radiusKm) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await for (final places in _repository
          .getNearbyPlaces(lat: lat, lng: lng, radiusKm: radiusKm)
          .take(1)) {
        _places = places;
        _isLoading = false;
        notifyListeners();
        break;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
