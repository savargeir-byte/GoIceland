import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/admin_place.dart';
import '../services/admin_service.dart';
import '../../core/constants/categories.dart'; // Shared categories

/// ✏️ Place Edit Screen - Edit place details and upload images
class PlaceEditScreen extends StatefulWidget {
  final String placeId;

  const PlaceEditScreen({
    super.key,
    required this.placeId,
  });

  @override
  State<PlaceEditScreen> createState() => _PlaceEditScreenState();
}

class _PlaceEditScreenState extends State<PlaceEditScreen>
    with SingleTickerProviderStateMixin {
  final _placeService = AdminPlaceService();
  final _formKey = GlobalKey<FormState>();

  late TabController _tabController;
  AdminPlace? _place;
  bool _isLoading = true;
  bool _isSaving = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _regionController = TextEditingController();

  // Multi-language content controllers
  final Map<String, Map<String, TextEditingController>> _contentControllers = {
    'en': {
      'description': TextEditingController(),
      'history': TextEditingController(),
      'tips': TextEditingController(),
    },
    'zh': {
      'description': TextEditingController(),
      'history': TextEditingController(),
      'tips': TextEditingController(),
    },
    'is': {
      'description': TextEditingController(),
      'history': TextEditingController(),
      'tips': TextEditingController(),
    },
  };

  String _category = 'attraction';
  final List<String> _services = [];
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPlace();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _regionController.dispose();
    for (final langControllers in _contentControllers.values) {
      for (final controller in langControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadPlace() async {
    final doc = await FirebaseFirestore.instance
        .collection('places')
        .doc(widget.placeId)
        .get();

    if (!doc.exists) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final place = AdminPlace.fromFirestore(doc);

    setState(() {
      _place = place;
      _nameController.text = place.name;
      _regionController.text = place.region ?? '';
      _category = place.category;
      _services.addAll(place.services);
      _tags.addAll(place.tags);

      // Load multi-language content
      place.content.forEach((lang, content) {
        if (_contentControllers.containsKey(lang)) {
          _contentControllers[lang]!['description']!.text =
              content.description ?? '';
          _contentControllers[lang]!['history']!.text = content.history ?? '';
          _contentControllers[lang]!['tips']!.text = content.tips ?? '';
        }
      });

      _isLoading = false;
    });
  }

  Future<void> _savePlace() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Build content map
      final contentMap = <String, Map<String, dynamic>>{};
      _contentControllers.forEach((lang, controllers) {
        final desc = controllers['description']!.text.trim();
        final hist = controllers['history']!.text.trim();
        final tips = controllers['tips']!.text.trim();

        if (desc.isNotEmpty || hist.isNotEmpty || tips.isNotEmpty) {
          contentMap[lang] = {
            if (desc.isNotEmpty) 'description': desc,
            if (hist.isNotEmpty) 'history': hist,
            if (tips.isNotEmpty) 'tips': tips,
          };
        }
      });

      final data = {
        'name': _nameController.text.trim(),
        'category': _category,
        'type': _category,
        'region': _regionController.text.trim(),
        'content': contentMap,
        'services': _services,
        'tags': _tags,
      };

      await _placeService.updatePlace(widget.placeId, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Place saved successfully!')),
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

      final url = await _placeService.uploadImage(widget.placeId, imageData);
      await _placeService.addImageToGallery(widget.placeId, url);

      // Reload place
      await _loadPlace();

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

  Future<void> _setCoverImage(String url) async {
    await _placeService.setCoverImage(widget.placeId, url);
    await _loadPlace();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cover image updated!')),
      );
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
      await _placeService.removeImageFromGallery(widget.placeId, url);
      await _loadPlace();
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
        title: Text(_place?.name ?? 'Edit Place'),
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
              onPressed: _savePlace,
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
                  labelText: 'Place Name',
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
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: PlaceCategories.all
                          .map((cat) => DropdownMenuItem(
                                value: cat.id,
                                child: Text('${cat.emoji} ${cat.label}'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v!),
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
              const SizedBox(height: 24),

              // Images section - Upload images for this place
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
                height: 500,
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

  Widget _buildImagesSection() {
    final images = _place?.images;
    final hasImages =
        (images?.gallery.isNotEmpty ?? false) || images?.cover != null;

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
                  itemCount: images!.gallery.length,
                  itemBuilder: (context, index) {
                    final url = images.gallery[index];
                    final isCover = url == images.cover;
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
                                    onTap: () => _setCoverImage(url),
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
        ],
      ),
    );
  }
}
