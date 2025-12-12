import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(offset: Offset(0, 8), blurRadius: 24, color: Colors.black12),
        ],
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: card);
  }
}
