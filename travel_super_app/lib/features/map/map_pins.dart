import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapPin extends StatelessWidget {
  const MapPin({super.key, required this.asset, this.selected = false});

  final String asset;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (selected)
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x334A90E2),
            ),
          ),
        SvgPicture.asset(asset, width: 36, height: 36),
      ],
    );
  }
}
