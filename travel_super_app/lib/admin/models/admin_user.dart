import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔐 User roles for admin access control
enum UserRole {
  admin,
  editor,
  viewer,
}

/// User model with role-based permissions
class AdminUser {
  final String uid;
  final String email;
  final UserRole role;
  final String? displayName;

  const AdminUser({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get canEdit => role == UserRole.admin || role == UserRole.editor;
  bool get canView => true;

  factory AdminUser.fromFirestore(String uid, Map<String, dynamic> data) {
    return AdminUser(
      uid: uid,
      email: data['email'] ?? '',
      role: _parseRole(data['role']),
      displayName: data['displayName'],
    );
  }

  static UserRole _parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'editor':
        return UserRole.editor;
      default:
        return UserRole.viewer;
    }
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'role': role.name,
        'displayName': displayName,
        'updatedAt': FieldValue.serverTimestamp(),
      };
}
