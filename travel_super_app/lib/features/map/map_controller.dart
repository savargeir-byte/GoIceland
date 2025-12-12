import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

import '../../data/models/poi_model.dart';

class TravelMapController {
  TravelMapController(this._controller);

  final MapboxMapController _controller;

  void showPois(List<PoiModel> pois) {
    for (final poi in pois) {
      _controller.addSymbol(
        SymbolOptions(
          geometry: LatLng(poi.latitude, poi.longitude),
          iconImage: 'assets/icons/pin_default',
          iconSize: 0.6,
          textField: poi.name,
          textOffset: const Offset(0, 1.4),
        ),
      );
    }
  }
}
