import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/api/poi_api.dart';
import '../../data/models/poi_model.dart';

/// 📊 Database Inspector Screen
/// Shows all POIs from Firebase with filtering and search
class DatabaseInspectorScreen extends StatefulWidget {
  const DatabaseInspectorScreen({super.key});

  @override
  State<DatabaseInspectorScreen> createState() => _DatabaseInspectorScreenState();
}

class _DatabaseInspectorScreenState extends State<DatabaseInspectorScreen> {
  final _poiApi = PoiApi();
  late Future<List<PoiModel>> _poiFuture;
  String _searchQuery = '';
  String? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _poiFuture = _poiApi.fetchFeatured();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Crystal Glass effect
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: Colors.white.withOpacity(0.12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.storage, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          const Text(
                            'Database Inspector',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.white70),
                            onPressed: () {
                              setState(() {
                                _poiFuture = _poiApi.fetchFeatured();
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Search bar
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search places...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Results
            Expanded(
              child: FutureBuilder<List<PoiModel>>(
                future: _poiFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  
                  final allPois = snapshot.data ?? [];
                  
                  // Filter POIs
                  final filteredPois = allPois.where((poi) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        poi.name.toLowerCase().contains(_searchQuery) ||
                        poi.type.toLowerCase().contains(_searchQuery);
                    
                    final matchesCategory = _selectedCategory == null ||
                        poi.type == _selectedCategory;
                    
                    return matchesSearch && matchesCategory;
                  }).toList();
                  
                  // Group by category
                  final byCategory = <String, List<PoiModel>>{};
                  for (final poi in filteredPois) {
                    byCategory.putIfAbsent(poi.type, () => []).add(poi);
                  }
                  
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Stats
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white.withOpacity(0.08),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatCard(
                                  label: 'Total',
                                  value: allPois.length.toString(),
                                  icon: Icons.place,
                                ),
                                _StatCard(
                                  label: 'Filtered',
                                  value: filteredPois.length.toString(),
                                  icon: Icons.filter_list,
                                ),
                                _StatCard(
                                  label: 'Categories',
                                  value: byCategory.length.toString(),
                                  icon: Icons.category,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Category chips
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _CategoryChip(
                              label: 'All',
                              count: allPois.length,
                              isSelected: _selectedCategory == null,
                              onTap: () {
                                setState(() {
                                  _selectedCategory = null;
                                });
                              },
                            ),
                            ...byCategory.entries.map((entry) {
                              return _CategoryChip(
                                label: entry.key,
                                count: entry.value.length,
                                isSelected: _selectedCategory == entry.key,
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = entry.key;
                                  });
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // POI list
                      ...byCategory.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              child: Text(
                                '${entry.key.toUpperCase()} (${entry.value.length})',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            ...entry.value.map((poi) => _PoiTile(poi: poi)),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),
                      
                      const SizedBox(height: 80),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _CategoryChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.08),
          border: Border.all(
            color: isSelected ? Colors.white.withOpacity(0.5) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PoiTile extends StatelessWidget {
  final PoiModel poi;
  
  const _PoiTile({required this.poi});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.08),
      ),
      child: Row(
        children: [
          // Image or placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.1),
            ),
            child: poi.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      poi.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.place,
                        color: Colors.white54,
                      ),
                    ),
                  )
                : const Icon(Icons.place, color: Colors.white54),
          ),
          
          const SizedBox(width: 12),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  poi.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${poi.latitude.toStringAsFixed(4)}, ${poi.longitude.toStringAsFixed(4)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Rating
          if (poi.rating != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    poi.rating!.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
