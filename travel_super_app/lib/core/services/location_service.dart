import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> currentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }

      return Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } on Exception {
      return null;
    }
  }
}
