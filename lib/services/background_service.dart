import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  // Iniciar sesión anónima (solo una vez)
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }
  final userId = auth.currentUser!.uid;

  // Leer intervalo desde Firestore (se actualiza en tiempo real)
  int intervalMinutes = 5;
  final configRef = firestore.collection('settings').doc('location_config');

  configRef.snapshots().listen((snapshot) {
    if (snapshot.exists) {
      intervalMinutes = snapshot['interval_minutes'] as int;
      print("Intervalo actualizado a $intervalMinutes minutos");
    }
  });

  // Timer que se ejecuta cada X minutos
  Timer.periodic(Duration(minutes: intervalMinutes), (timer) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final geohasher = GeoHasher();
      final geohash = geohasher.encode(
        position.latitude,
        position.longitude,
        precision: 9,   // ≈ 5 km
      );

      await firestore.collection('locations').add({
        'userId': userId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'geohash': geohash,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Ubicación enviada: ${position.latitude}, ${position.longitude} - geohash: $geohash");
    } catch (e) {
      print("Error al obtener ubicación: $e");
    }
  });
}