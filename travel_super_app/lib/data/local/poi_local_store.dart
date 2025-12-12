import '../models/poi_model.dart';

class PoiLocalStore {
  final _cached = <PoiModel>[];

  List<PoiModel> get all => List.unmodifiable(_cached);

  void upsertAll(List<PoiModel> pois) {
    _cached
      ..clear()
      ..addAll(pois);
  }
}
