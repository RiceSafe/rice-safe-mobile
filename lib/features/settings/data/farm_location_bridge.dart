import 'package:latlong2/latlong.dart';

/// In-memory farm coordinates synced with [FarmLocationSettingsScreen.savedLocation] and persistence.
class FarmLocationBridge {
  FarmLocationBridge._();

  static LatLng? value;
}
