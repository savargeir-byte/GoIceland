import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_login_screen.dart';

/// 🔐 Admin App Entry Point
///
/// This is a standalone admin app for managing Go Iceland content.
/// To use this, create a separate main_admin.dart or integrate into your main app routing.
///
/// Usage:
/// ```bash
/// # Run admin panel on web
/// flutter run -d chrome --target lib/admin/admin_app.dart
///
/// # Build admin panel for web deployment
/// flutter build web --target lib/admin/admin_app.dart
/// ```
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Iceland Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            return const AdminDashboardScreen();
          }

          return const AdminLoginScreen();
        },
      ),
    );
  }
}

/// Initialize and run admin app
Future<void> runAdminApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AdminApp());
}

/// Main entry point for admin app
void main() async {
  await runAdminApp();
}
