// lib/service/location_service.dart

import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

Future<Position> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    return Future.error('Location service is disabled');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permission is denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permission is denied forever, we cannot request');
  }
  return Geolocator.getCurrentPosition();
}

class LocationService {
  Location location = Location();
  late LocationData _locData;

  Future<void> initialize() async {
    bool _serviceEnable;
    PermissionStatus _permission;

    _serviceEnable = await location.serviceEnabled();
    if (!_serviceEnable) {
      _serviceEnable = await location.requestService();
      if (!_serviceEnable) {
        return;
      }
    }
    _permission = await location.hasPermission();
    if (_permission == PermissionStatus.denied) {
      _permission = await location.requestPermission();
      if (_permission != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<double?> getLatitude() async {
    _locData = await location.getLocation();
    return _locData.latitude;
  }

  Future<double?> getLongitude() async {
    _locData = await location.getLocation();
    return _locData.longitude;
  }
}
