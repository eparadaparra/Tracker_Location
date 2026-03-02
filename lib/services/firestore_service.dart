import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tracker_location/models/location_ping.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<int> getIntervalMinutes() async {
    final snap = await _db.collection('app_config').doc('default').get();
    final data = snap.data();
    final minutes = (data?['intervalMinutes'] ?? 5);
    return (minutes is int) ? minutes : (minutes as num).toInt();
  }

  Future<void> savePing({required String uid, required LocationPing ping}) async {
    final now = DateTime.now().toUtc();
    final pingId =
        '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}_'
        '${now.millisecond.toString().padLeft(3, '0')}';
        
    final doc = _db
      .collection('users')
      .doc(uid)
      .collection('location_pings')
      .doc(pingId);

    await doc.set({
      ...ping.toMap(),
      'geopoint': GeoPoint(ping.latitude, ping.longitude),
      'day': DateTime.now().toIso8601String().substring(0, 10), // YYYY-MM-DD
      'timestamp': FieldValue.serverTimestamp(),
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