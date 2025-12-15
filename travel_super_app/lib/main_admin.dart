import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'admin/admin_app.dart';
import 'firebase_options.dart';

/// 🔐 Admin Panel Entry Point
/// 
/// Run this to start the admin panel:
/// ```bash
/// flutter run -d chrome --target lib/main_admin.dart
/// ```
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AdminApp());
}
