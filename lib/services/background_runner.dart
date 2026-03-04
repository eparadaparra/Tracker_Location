import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tracker_location/firebase_options.dart';
import 'package:tracker_location/models/location_ping.dart';
import 'package:tracker_location/services/services.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

final FlutterLocalNotificationsPlugin _notifications =
    FlutterLocalNotificationsPlugin();

class BackgroundRunner {
  
  static Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _notifications.initialize(initSettings);

    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: backgroundOnStart,
        isForegroundMode: true,
        autoStart: false,
        foregroundServiceNotificationId: 777,
        initialNotificationTitle: 'Tracker activo',
        initialNotificationContent: 'Enviando ubicación...',
      ),
      iosConfiguration: IosConfiguration(
        onForeground: backgroundOnStart,
        onBackground: (_) async => true,
      ),
    );
  }

  static Future<void> persistUser({ required String uid, required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tracker_uid', uid);
    await prefs.setString('tracker_email', email);
  }

  static Future<void> start() async {
    final service = FlutterBackgroundService();
    await service.startService();
  }

  static Future<void> stop() async {
    FlutterBackgroundService().invoke("stopService");
  }

}

/// ✅ TOP-LEVEL + PRAGMA
@pragma('vm:entry-point')
Future<void> backgroundOnStart(ServiceInstance service) async {
  
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  service.on("stopService").listen((_) {
    service.stopSelf();
  });

  final firestore = FirestoreService();
  final location = LocationService();
  // ✅ Lee uid/email desde SharedPreferences (ya NO usamos setUser)
  final prefs = await SharedPreferences.getInstance();
  final uid   = prefs.getString('tracker_uid');
  final email = prefs.getString('tracker_email');

  print('[BG] prefs uid=$uid email=$email');

  if (uid == null || email == null) {
    print('[BG] No hay uid/email en prefs. Deteniendo servicio.');
    service.stopSelf();
    return;
  }

  Future<void> sendPingOnce() async {
    try {
      final pos = await location.getCurrentPosition();
      final geo = GeoFirePoint(
        GeoPoint(pos.latitude, pos.longitude)
      );
      final ping = LocationPing(
        email: email,
        userId: uid,
        geolocation: Geolocation(
          geohash: geo.geohash, 
          geopoint: GeoPoint(pos.latitude, pos.longitude),
        ),
      );

      await firestore.savePing(
        uid: uid,
        ping: ping,
      );

      print('[BG] Ping guardado uid=$uid lat=${pos.latitude} lng=${pos.longitude}');

      await _notifications.show(
        777,
        'Tracker activo',
        'Último envío: ${DateTime.now()}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tracker_channel',
            'Tracker',
            importance: Importance.low,
            priority: Priority.low,
          ),
        ),
      );
    } catch (e, st) {
      print('[BG] ERROR enviando ping: $e');
      print(st);
    }
  }

  // ✅ Loop dinámico
  while (true) {
    await sendPingOnce();
    final secs = await firestore.getIntervalSeconds();
    await Future.delayed( Duration(seconds: secs) );
  }
}