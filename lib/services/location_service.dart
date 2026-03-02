import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<void> ensurePermissions() async {
    // Notificaciones (para foreground service)
    await Permission.notification.request();

    // Ubicación foreground
    final loc = await Permission.locationWhenInUse.request();
    if (!loc.isGranted) {
      throw Exception('Permiso de ubicación (WhenInUse) denegado.');
    }

    // Ubicación background
    final bg = await Permission.locationAlways.request();
    if (!bg.isGranted) {
      throw Exception('Permiso de ubicación en segundo plano (Always) denegado.');
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Servicios de ubicación desactivados.');
    }
  }

  Future<Position> getCurrentPosition() async {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}