import 'package:flutter/material.dart';

class AuroraIndicator extends StatelessWidget {
  const AuroraIndicator({super.key, required this.activityIndex});

  final double activityIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aurora activity ${(activityIndex * 100).toStringAsFixed(0)}%'),
        const SizedBox(height: 4),
        LinearProgressIndicator(value: activityIndex.clamp(0, 1)),
      ],
    );
  }
}
