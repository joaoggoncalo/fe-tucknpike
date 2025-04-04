import 'package:geocoding/geocoding.dart';

/// A service to convert coordinates into a human-readable address.
class GeocodingService {
  /// Returns an address string (street, locality, country) for the given coordinates.
  /// If no address is found, returns null.
  Future<String?> getAddress(double latitude, double longitude) async {
    final placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return '${place.street}, ${place.locality}, ${place.country}';
    }
    return null;
  }
}
