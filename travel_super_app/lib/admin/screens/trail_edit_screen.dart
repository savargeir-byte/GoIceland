import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/admin_trail.dart';
import '../services/admin_trail_service.dart';

/// ✏️ Trail Edit Screen - Edit trail details and upload images
class TrailEditScreen extends StatefulWidget {
  final String trailId;

  const TrailEditScreen({
    super.key,
    required this.trailId,
  });

  @override
  State<TrailEditScreen> createState() => _TrailEditScreenState();
}

class _TrailEditScreenState extends State<TrailEditScreen>
    with SingleTickerProviderStateMixin {
  final _trailService = AdminTrailService();
  final _formKey = GlobalKey<FormState>();

  late TabController _tabController;
  AdminTrail? _trail;
  bool _isLoading = true;
  bool _isSaving = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _regionController = TextEditingController();
  final _lengthController = TextEditingController();
  final _durationController = TextEditingController();
  final _elevationController = TextEditingController();

  // Multi-language content controllers
  final Map<String, Map<String, TextEditingController>> _contentControllers = {
    'en': {
      'description': TextEditingController(),
      'history': TextEditingController(),
      'tips': TextEditingController(),
      'safety': TextEditingController(),
    },
    'zh': {
      'description': TextEditingController(),
      'history': TextEditingController(),
      'tips': TextEditingController(),
      'safety': TextEditingController(),
    },
    'is': {
      'description': TextEditingController(),
      'history': TextEditingController(),
      'tips': TextEditingController(),
      'safety': TextEditingController(),
    },
  };

  String _difficulty = 'moderate';
  bool _hasCamping = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTrail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _regionController.dispose();
    _lengthController.dispose();
    _durationController.dispose();
    _elevationController.dispose();
    for (final langControllers in _contentControllers.values) {
      for (final controller in langControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadTrail() async {
    final doc = await FirebaseFirestore.instance
        .collection('trails')
        .doc(widget.trailId)
        .get();

    if (!doc.exists) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final trail = AdminTrail.fromFirestore(doc);

    setState(() {
      _trail = trail;
      _nameController.text = trail.name;
      _regionController.text = trail.region ?? '';
      _lengthController.text = trail.lengthKm?.toString() ?? '';
      _durationController.text = trail.durationMin?.toString() ?? '';
      _elevationController.text = trail.elevationGain?.toString() ?? '';
      _difficulty = trail.difficulty?.toLowerCase() ?? 'moderate';
      _hasCamping = trail.hasCamping ?? false;

      // Load multi-language content
      trail.content.forEach((lang, content) {
        if (_contentControllers.containsKey(lang)) {
          _contentControllers[lang]!['description']!.text =
              content.description ?? '';
          _contentControllers[lang]!['history']!.text = content.history ?? '';
          _contentControllers[lang]!['tips']!.text = content.tips ?? '';
          _contentControllers[lang]!['safety']!.text = content.safety ?? '';
        }
      });

      _isLoading = false;
    });
  }

  Future<void> _saveTrail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Build content map
      final contentMap = <String, Map<String, dynamic>>{};
      _contentControllers.forEach((lang, controllers) {
        final desc = controllers['description']!.text.trim();
        final hist = controllers['history']!.text.trim();
        final tips = controllers['tips']!.text.trim();
        final safety = controllers['safety']!.text.trim();

        if (desc.isNotEmpty ||
            hist.isNotEmpty ||
            tips.isNotEmpty ||
            safety.isNotEmpty) {
          contentMap[lang] = {
            if (desc.isNotEmpty) 'description': desc,
            if (hist.isNotEmpty) 'history': hist,
            if (tips.isNotEmpty) 'tips': tips,
            if (safety.isNotEmpty) 'safety': safety,
          };
        }
      });

      final data = {
        'name': _nameController.text.trim(),
        'difficulty': _difficulty,
        'region': _regionController.text.trim(),
        'lengthKm': double.tryParse(_lengthController.text.trim()),
        'durationMin': int.tryParse(_durationController.text.trim()),
        'elevationGain': int.tryParse(_elevationController.text.trim()),
        'hasCamping': _hasCamping,
        'content': contentMap,
      };

      await _trailService.updateTrail(widget.trailId, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Trail saved successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isSaving = true);

    try {
      dynamic imageData;

      if (kIsWeb) {
        // On web, read as bytes
        imageData = await image.readAsBytes();
      } else {
        // On mobile, use File
        imageData = File(image.path);
      }

      final url = await _trailService.uploadImage(widget.trailId, imageData);
      await _trailService.addImageToGallery(widget.trailId, url);

      // Reload trail
      await _loadTrail();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Image uploaded!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteImage(String url) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);
    try {
      await _trailService.removeImageFromGallery(widget.trailId, url);
      await _loadTrail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Image deleted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_trail?.name ?? 'Edit Trail'),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveTrail,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic info
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Trail Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _difficulty,
                      decoration: const InputDecoration(
                        labelText: 'Difficulty',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'easy', child: Text('🟢 Easy')),
                        DropdownMenuItem(
                            value: 'moderate', child: Text('🟡 Moderate')),
                        DropdownMenuItem(value: 'hard', child: Text('🟠 Hard')),
                        DropdownMenuItem(
                            value: 'expert', child: Text('🔴 Expert')),
                      ],
                      onChanged: (v) => setState(() => _difficulty = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _regionController,
                      decoration: const InputDecoration(
                        labelText: 'Region',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Trail stats
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lengthController,
                      decoration: const InputDecoration(
                        labelText: 'Length (km)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _elevationController,
                      decoration: const InputDecoration(
                        labelText: 'Elevation (m)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Camping checkbox
              CheckboxListTile(
                title: const Text('Has Camping'),
                subtitle: const Text('Trail includes camping facilities'),
                value: _hasCamping,
                onChanged: (v) => setState(() => _hasCamping = v ?? false),
              ),
              const SizedBox(height: 24),

              // Trail Map section - Show OpenStreetMap
              if (_trail?.mapImage != null) _buildTrailMapSection(),
              const SizedBox(height: 16),

              // Images section - Upload images for this trail
              _buildImagesSection(),
              const SizedBox(height: 24),

              // Multi-language content tabs
              const Text(
                'Descriptions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                tabs: const [
                  Tab(text: '🇬🇧 English'),
                  Tab(text: '🇨🇳 Chinese'),
                  Tab(text: '🇮🇸 Icelandic'),
                ],
              ),
              SizedBox(
                height: 600,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildContentTab('en'),
                    _buildContentTab('zh'),
                    _buildContentTab('is'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrailMapSection() {
    final mapUrl = _trail?.mapImage;
    if (mapUrl == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.map, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Trail Map',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    // OpenStreetMap iframe - using InAppWebView or similar
                    // For now, show a placeholder with link
                    Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.map_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () async {
                                // Open in browser
                                final uri = Uri.parse(mapUrl);
                                // TODO: Add url_launcher to open in browser
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Map URL: $mapUrl')),
                                  );
                                }
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('View Map in Browser'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Interactive trail map from OpenStreetMap',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    final images = _trail?.images ?? [];
    final hasImages = images.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Images',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _pickAndUploadImage,
                  icon: const Icon(Icons.upload),
                  label: const Text('Upload'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasImages)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final url = images[index];
                    final isCover = url == _trail?.coverImage;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isCover ? Colors.blue : Colors.grey,
                                width: isCover ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(url, fit: BoxFit.cover),
                            ),
                          ),
                          if (isCover)
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'COVER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: PopupMenuButton(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.white),
                              itemBuilder: (context) => [
                                if (!isCover)
                                  PopupMenuItem(
                                    child: const Text('Set as cover'),
                                    onTap: () async {
                                      await _trailService.setCoverImage(
                                          widget.trailId, url);
                                      await _loadTrail();
                                    },
                                  ),
                                PopupMenuItem(
                                  child: const Text('Delete'),
                                  onTap: () => _deleteImage(url),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              const Text('No images yet. Upload images to get started.'),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTab(String lang) {
    final controllers = _contentControllers[lang]!;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          TextFormField(
            controller: controllers['description']!,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controllers['history']!,
            decoration: const InputDecoration(
              labelText: 'History',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controllers['tips']!,
            decoration: const InputDecoration(
              labelText: 'Tips & Recommendations',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controllers['safety']!,
            decoration: const InputDecoration(
              labelText: 'Safety Information',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
