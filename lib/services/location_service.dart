import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Flag to control if live location is available
  static const bool _isLiveLocationAvailable = false; // Set to false for "coming soon"

  static bool get isLiveLocationAvailable => _isLiveLocationAvailable;

  static Future<bool> requestLocationPermission() async {
    if (!_isLiveLocationAvailable) {
      throw Exception('Live location is not available yet. Coming soon!');
    }
    
    PermissionStatus status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> checkLocationPermission() async {
    if (!_isLiveLocationAvailable) {
      return false; // Return false to indicate location is not available
    }
    
    PermissionStatus status = await Permission.location.status;
    return status.isGranted;
  }

  static Future<bool> isLocationServiceEnabled() async {
    if (!_isLiveLocationAvailable) {
      return false; // Return false to indicate location service is not available
    }
    
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<Position?> getCurrentPosition() async {
    if (!_isLiveLocationAvailable) {
      throw Exception('Live location is not available yet. Coming soon!');
    }
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable them in your device settings.');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('Error getting current position: $e');
      return null;
    }
  }

  static Future<String?> getCityFromPosition(Position position) async {
    if (!_isLiveLocationAvailable) {
      return null;
    }
    
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return place.locality ?? place.subAdministrativeArea ?? place.administrativeArea;
      }
      return null;
    } catch (e) {
      print('Error getting city from position: $e');
      return null;
    }
  }

  static Future<String?> getCurrentCity() async {
    if (!_isLiveLocationAvailable) {
      return null;
    }
    
    try {
      Position? position = await getCurrentPosition();
      if (position != null) {
        return await getCityFromPosition(position);
      }
      return null;
    } catch (e) {
      print('Error getting current city: $e');
      return null;
    }
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}
