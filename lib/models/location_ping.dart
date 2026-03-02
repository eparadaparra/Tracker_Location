class LocationPing {
  final String email;
  final String userId;
  final String geohash;
  final double latitude;
  final double longitude;

  LocationPing({
    required this.email,
    required this.userId,
    required this.geohash,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() => {
        'email': email,
        'userId': userId,
        'geohash': geohash,
        'latitude': latitude,
        'longitude': longitude,
        // timestamp se setea como serverTimestamp en FirestoreService
      };
}