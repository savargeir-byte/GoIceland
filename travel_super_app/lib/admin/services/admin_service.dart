import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/admin_user.dart';

/// 🔐 Authentication service for admin panel
class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current admin user with role
  Future<AdminUser?> getCurrentAdminUser() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AdminUser.fromFirestore(user.uid, doc.data()!);
  }

  /// Check if current user has editor role or above
  Future<bool> canEdit() async {
    final adminUser = await getCurrentAdminUser();
    return adminUser?.canEdit ?? false;
  }

  /// Check if current user is admin
  Future<bool> isAdmin() async {
    final adminUser = await getCurrentAdminUser();
    return adminUser?.isAdmin ?? false;
  }

  /// Sign in with email and password
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Listen to auth state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}

/// 📍 Place management service
class AdminPlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get all places (paginated)
  Stream<QuerySnapshot> getPlaces({
    String? category,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) {
    Query query = _firestore.collection('places');

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    query = query.limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots();
  }

  /// Search places by name
  Future<List<DocumentSnapshot>> searchPlaces(String searchTerm) async {
    final snapshot = await _firestore
        .collection('places')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThan: '${searchTerm}z')
        .limit(20)
        .get();

    return snapshot.docs;
  }

  /// Get single place
  Stream<DocumentSnapshot> getPlace(String placeId) {
    return _firestore.collection('places').doc(placeId).snapshots();
  }

  /// Update place
  Future<void> updatePlace(
    String placeId,
    Map<String, dynamic> data,
  ) async {
    final userId = _auth.currentUser?.uid;
    data['updatedBy'] = userId;
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('places').doc(placeId).update(data);
  }

  /// Create new place
  Future<String> createPlace(Map<String, dynamic> data) async {
    final userId = _auth.currentUser?.uid;
    data['updatedBy'] = userId;
    data['updatedAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection('places').add(data);
    return docRef.id;
  }

  /// Delete place
  Future<void> deletePlace(String placeId) async {
    await _firestore.collection('places').doc(placeId).delete();
    // TODO: Also delete images from storage
  }

  /// Upload image to Firebase Storage
  Future<String> uploadImage(
    String placeId,
    dynamic imageFile, {
    String? fileName,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final name = fileName ?? 'image_$timestamp.jpg';
    final ref = _storage.ref('places/$placeId/$name');

    // Handle web vs mobile upload
    if (kIsWeb) {
      // For web: imageFile should be Uint8List
      if (imageFile is Uint8List) {
        await ref.putData(imageFile);
      } else {
        throw Exception('For web, imageFile must be Uint8List');
      }
    } else {
      // For mobile: imageFile should be File
      if (imageFile is File) {
        await ref.putFile(imageFile);
      } else {
        throw Exception('For mobile, imageFile must be File');
      }
    }

    final url = await ref.getDownloadURL();

    return url;
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  /// Add image to place gallery
  Future<void> addImageToGallery(String placeId, String imageUrl) async {
    await _firestore.collection('places').doc(placeId).update({
      'images.gallery': FieldValue.arrayUnion([imageUrl]),
      'images': FieldValue.arrayUnion([imageUrl]), // Backward compatibility
    });
  }

  /// Remove image from place gallery
  Future<void> removeImageFromGallery(String placeId, String imageUrl) async {
    await _firestore.collection('places').doc(placeId).update({
      'images.gallery': FieldValue.arrayRemove([imageUrl]),
      'images': FieldValue.arrayRemove([imageUrl]), // Backward compatibility
    });

    // Delete from storage
    await deleteImage(imageUrl);
  }

  /// Set cover image
  Future<void> setCoverImage(String placeId, String imageUrl) async {
    await _firestore.collection('places').doc(placeId).update({
      'images.cover': imageUrl,
      'images.hero_image': imageUrl, // Backward compatibility
      'image': imageUrl, // Backward compatibility
    });
  }

  /// Get categories with counts
  Future<Map<String, int>> getCategoryCounts() async {
    final snapshot = await _firestore.collection('places').get();
    final counts = <String, int>{};

    for (final doc in snapshot.docs) {
      final category = doc.data()['category'] ?? 'unknown';
      counts[category] = (counts[category] ?? 0) + 1;
    }

    return counts;
  }
}

/// 🥾 Trail management service
class AdminTrailService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get all trails (paginated)
  Stream<QuerySnapshot> getTrails({
    String? difficulty,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) {
    Query query = _firestore.collection('trails');

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }

    query = query.limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots();
  }

  /// Get single trail
  Stream<DocumentSnapshot> getTrail(String trailId) {
    return _firestore.collection('trails').doc(trailId).snapshots();
  }

  /// Update trail
  Future<void> updateTrail(
    String trailId,
    Map<String, dynamic> data,
  ) async {
    final userId = _auth.currentUser?.uid;
    data['updatedBy'] = userId;
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('trails').doc(trailId).update(data);
  }

  /// Upload image to Firebase Storage
  Future<String> uploadImage(
    String trailId,
    dynamic imageFile, {
    String? fileName,
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final name = fileName ?? 'image_$timestamp.jpg';
    final ref = _storage.ref('trails/$trailId/$name');

    // Handle web vs mobile upload
    if (kIsWeb) {
      // For web: imageFile should be Uint8List
      if (imageFile is Uint8List) {
        await ref.putData(imageFile);
      } else {
        throw Exception('For web, imageFile must be Uint8List');
      }
    } else {
      // For mobile: imageFile should be File
      if (imageFile is File) {
        await ref.putFile(imageFile);
      } else {
        throw Exception('For mobile, imageFile must be File');
      }
    }

    final url = await ref.getDownloadURL();

    return url;
  }

  /// Add image to trail gallery
  Future<void> addImageToGallery(String trailId, String imageUrl) async {
    await _firestore.collection('trails').doc(trailId).update({
      'images': FieldValue.arrayUnion([imageUrl]),
    });
  }

  /// Remove image from trail gallery
  Future<void> removeImageFromGallery(String trailId, String imageUrl) async {
    await _firestore.collection('trails').doc(trailId).update({
      'images': FieldValue.arrayRemove([imageUrl]),
    });

    // Delete from storage
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  /// Set cover image
  Future<void> setCoverImage(String trailId, String imageUrl) async {
    await _firestore.collection('trails').doc(trailId).update({
      'coverImage': imageUrl,
    });
  }
}
