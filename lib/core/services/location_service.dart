import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<bool> checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<String> getAddressFromPosition(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return _formatPlacemark(place);
      }
      return 'Unknown location';
    } catch (e) {
      return 'Unable to fetch address';
    }
  }

  static String _formatPlacemark(Placemark place) {
    final parts = <String>[];

    if (place.subThoroughfare != null)
      parts.add('No: ${place.subThoroughfare}');
    if (place.thoroughfare != null) parts.add(place.thoroughfare!);
    if (place.subLocality != null) parts.add(place.subLocality!);
    if (place.locality != null) parts.add(place.locality!);
    if (place.administrativeArea != null) parts.add(place.administrativeArea!);
    if (place.postalCode != null) parts.add(place.postalCode!);
    if (place.country != null) parts.add(place.country!);

    return parts.join(', ');
  }

  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
