import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/models/poi_category.dart';
import '../widgets/category_chip.dart';

/// 🎛️ Filters Screen
class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  State<FiltersScreen> createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  final Set<String> _selectedCategories = {};
  String? _selectedDifficulty;
  RangeValues _ratingRange = const RangeValues(0, 5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Filters',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategories.clear();
                _selectedDifficulty = null;
                _ratingRange = const RangeValues(0, 5);
              });
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Categories
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: IcelandCategories.allCategories
                .where((c) => c.id != 'all')
                .map((category) {
              final isSelected = _selectedCategories.contains(category.name);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCategories.remove(category.name);
                    } else {
                      _selectedCategories.add(category.name);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? category.color
                          : Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (category.emoji != null) ...[
                        Text(
                          category.emoji!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        category.displayName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Trail Difficulty
          const Text(
            'Trail Difficulty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            children: ['Easy', 'Moderate', 'Hard'].map((difficulty) {
              final isSelected = _selectedDifficulty == difficulty.toLowerCase();
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDifficulty =
                        isSelected ? null : difficulty.toLowerCase();
                  });
                },
                child: Chip(
                  label: Text(difficulty),
                  backgroundColor: isSelected
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  side: BorderSide(
                    color: isSelected ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Rating Range
          const Text(
            'Minimum Rating',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          RangeSlider(
            values: _ratingRange,
            min: 0,
            max: 5,
            divisions: 10,
            labels: RangeLabels(
              _ratingRange.start.toStringAsFixed(1),
              _ratingRange.end.toStringAsFixed(1),
            ),
            onChanged: (values) {
              setState(() {
                _ratingRange = values;
              });
            },
          ),

          const SizedBox(height: 40),

          // Apply Button
          ElevatedButton(
            onPressed: () {
              // TODO: Apply filters
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Apply Filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
