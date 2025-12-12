import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/repositories/offline_cache.dart';

/// 📡 Offline Screen - Download data for offline use
class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  OfflineCache? _cache;
  Map<String, dynamic>? _cacheStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCacheStats();
  }

  Future<void> _loadCacheStats() async {
    setState(() => _isLoading = true);
    _cache = await OfflineCache.init();
    _cacheStats = await _cache!.getCacheStats();
    setState(() => _isLoading = false);
  }

  Future<void> _downloadForOffline() async {
    // TODO: Implement download logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading data for offline use...'),
      ),
    );
  }

  Future<void> _clearCache() async {
    await _cache?.clearCache();
    await _loadCacheStats();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache cleared'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Offline Mode',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Download data to use the app without internet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Cache Stats Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Downloaded Data',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _StatRow(
                          icon: Icons.place,
                          label: 'Places',
                          value: '${_cacheStats?['placesCount'] ?? 0}',
                        ),
                        const SizedBox(height: 12),
                        _StatRow(
                          icon: Icons.hiking,
                          label: 'Trails',
                          value: '${_cacheStats?['trailsCount'] ?? 0}',
                        ),
                        const SizedBox(height: 12),
                        _StatRow(
                          icon: Icons.access_time,
                          label: 'Last synced',
                          value: _cacheStats?['lastSyncFormatted'] ?? 'Never',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Download Button
                  ElevatedButton.icon(
                    onPressed: _downloadForOffline,
                    icon: const Icon(Icons.download),
                    label: const Text('Download for Offline Use'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Clear Cache Button
                  if (_cacheStats?['hasPlacesCache'] == true ||
                      _cacheStats?['hasTrailsCache'] == true)
                    OutlinedButton.icon(
                      onPressed: _clearCache,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Clear Downloaded Data'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Downloaded data will be available even without internet connection',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
