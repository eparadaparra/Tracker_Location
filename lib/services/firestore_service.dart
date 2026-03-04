import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_location/models/location_ping.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> getIntervalSeconds() async {
    final snap = await _db.collection('settings').doc('location_config').get();
    final data = snap.data();
    
    final raw = data?['intervalSeconds'] ?? 300;
    final seconds = (raw is int) ? raw : (raw as num).toInt();
    return (seconds < 30) ? 30 : seconds;
  }

  Future<void> savePing({required String uid, required LocationPing ping}) async {
    final now = DateTime.now().toUtc();
    final day = now.toIso8601String().substring(0, 10); // YYYY-MM-DD (UTC)
    final pingId =
        '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}_'
        '${now.millisecond.toString().padLeft(3, '0')}';
        
    final doc = _db
      .collection('users')
      .doc(uid)
      .collection('daily_tracks')
      .doc(day)
      .collection('pings')
      .doc(pingId);
      //.collection('location_pings')

    await doc.set({
      ...ping.toMap(),
      'timestamp': FieldValue.serverTimestamp(),
      //'geopoint': ping.geolocation.geopoint,
      //'day': DateTime.now().toIso8601String().substring(0, 10), // YYYY-MM-DD
    });
  }

  Future<void> upsertUserProfile({required String uid, required String email}) async {
    final emailLower = email.trim().toLowerCase();

    // users/{uid}
    await _db.collection('users').doc(uid).set({
      'email': email,
      'emailLower': emailLower,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // users_by_email/{emailLower}
    await _db.collection('users_by_email').doc(emailLower).set({
      'uid': uid,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
      'uids': FieldValue.arrayUnion([uid]),
    }, SetOptions(merge: true));
  }

}