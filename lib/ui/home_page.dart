import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:tracker_location/services/services.dart';
import 'package:tracker_location/ui/ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = AuthService();
  final _location = LocationService();
  String? _status;

  Future<void> _start() async {
    try {
      await _location.ensurePermissions();
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No hay usuario logueado");

      final firestore = FirestoreService();
      await firestore.upsertUserProfile(
        uid: user.uid,
        email: user.email ?? '',
      );

      // 1) Guarda uid/email localmente para que el background pueda leerlos
      await BackgroundRunner.persistUser(
        uid: user.uid,
        email: user.email ?? '',
      );

      // 2) Arranca el servicio (sin depender de invoke setUser)
      await BackgroundRunner.start();

      setState(() => _status = 'Servicio iniciado');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _stop() async {
    await BackgroundRunner.stop();
    setState(() => _status = 'Servicio detenido');
  }

  Future<void> _logout() async {
    await _stop();
    await _auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Usuario: ${u?.email ?? '-'}'),
            const SizedBox(height: 8),
            if (_status != null) Text(_status!),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton(onPressed: _start, child: const Text('Iniciar tracking')),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: _stop, child: const Text('Detener')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}