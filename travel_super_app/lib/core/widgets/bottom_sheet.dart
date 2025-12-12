import 'package:flutter/material.dart';

class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(controller: controller, child: child),
          ),
        );
      },
    );
  }
}
