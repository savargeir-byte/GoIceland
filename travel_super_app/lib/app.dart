import 'package:flutter/material.dart';

import 'features/navigation/home_navigation_screen.dart';

class TravelSuperApp extends StatelessWidget {
  const TravelSuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GO ICELAND',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeNavigationScreen(),
    );
  }
}

