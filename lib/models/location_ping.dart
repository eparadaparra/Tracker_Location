import 'package:cloud_firestore/cloud_firestore.dart';

class LocationPing {
  final String email;
  final String userId;
  final Geolocation geolocation;

  LocationPing({
    required this.email,
    required this.userId,
    required this.geolocation,
  });

  Map<String, dynamic> toMap() => {
        'email': email,
        'userId': userId,
        'geolocation': geolocation.toMap(),
      };

  factory LocationPing.fromMap(Map<String, dynamic> map) {
    return LocationPing(
      email: map['email'] ?? '',
      userId: map['userId'] ?? '',
      geolocation: Geolocation.fromMap(
        Map<String, dynamic>.from(map['geolocation'] ?? {}),
      ),
    );
  }
}

class Geolocation {
  final String geohash;
  final GeoPoint geopoint;

  Geolocation({
    required this.geohash,
    required this.geopoint,
  });

  Map<String, dynamic> toMap() => {
        'geohash': geohash,
        'geopoint': geopoint,
      };

  factory Geolocation.fromMap(Map<String, dynamic> map) {
    return Geolocation(
      geohash: map['geohash'] ?? '',
      geopoint: map['geopoint'] is GeoPoint
          ? map['geopoint']
          : const GeoPoint(0, 0),
    );
  }
}