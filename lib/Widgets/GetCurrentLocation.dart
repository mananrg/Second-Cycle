import 'package:geolocator/geolocator.dart';

Future<Position> getUserPosition() async {
  Position currentPosition = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  return currentPosition;
}
