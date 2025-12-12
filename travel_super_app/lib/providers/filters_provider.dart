import 'package:flutter/material.dart';

/// 🎛️ FiltersProvider - State management for filter settings
class FiltersProvider extends ChangeNotifier {
  Set<String> _selectedCategories = {};
  String? _selectedDifficulty;
  RangeValues _ratingRange = const RangeValues(0, 5);
  double _maxDistance = 100; // km
  
  // Getters
  Set<String> get selectedCategories => _selectedCategories;
  String? get selectedDifficulty => _selectedDifficulty;
  RangeValues get ratingRange => _ratingRange;
  double get maxDistance => _maxDistance;
  
  /// Check if any filters are active
  bool get hasActiveFilters {
    return _selectedCategories.isNotEmpty ||
           _selectedDifficulty != null ||
           _ratingRange.start > 0 ||
           _ratingRange.end < 5 ||
           _maxDistance < 100;
  }
  
  /// Toggle category selection
  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }
  
  /// Set selected categories
  void setCategories(Set<String> categories) {
    _selectedCategories = categories;
    notifyListeners();
  }
  
  /// Clear all category filters
  void clearCategories() {
    _selectedCategories.clear();
    notifyListeners();
  }
  
  /// Set difficulty filter
  void setDifficulty(String? difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }
  
  /// Set rating range
  void setRatingRange(RangeValues range) {
    _ratingRange = range;
    notifyListeners();
  }
  
  /// Set max distance
  void setMaxDistance(double distance) {
    _maxDistance = distance;
    notifyListeners();
  }
  
  /// Clear all filters
  void clearAll() {
    _selectedCategories.clear();
    _selectedDifficulty = null;
    _ratingRange = const RangeValues(0, 5);
    _maxDistance = 100;
    notifyListeners();
  }
  
  /// Apply filters and return filtered list
  List<T> applyFilters<T>(List<T> items, {
    required String Function(T) getCategory,
    required double Function(T) getRating,
    String Function(T)? getDifficulty,
  }) {
    var filtered = items;
    
    // Filter by categories
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((item) =>
        _selectedCategories.contains(getCategory(item))
      ).toList();
    }
    
    // Filter by rating
    filtered = filtered.where((item) {
      final rating = getRating(item);
      return rating >= _ratingRange.start && rating <= _ratingRange.end;
    }).toList();
    
    // Filter by difficulty (if applicable)
    if (_selectedDifficulty != null && getDifficulty != null) {
      filtered = filtered.where((item) =>
        getDifficulty(item) == _selectedDifficulty
      ).toList();
    }
    
    return filtered;
  }
}
