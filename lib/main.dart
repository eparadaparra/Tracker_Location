import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tracker_location/ui/ui.dart';
import 'firebase_options.dart';
import 'services/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializa el background service (no lo arranca aún)
  await BackgroundRunner.initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker',
      theme: ThemeData(useMaterial3: true),
      home: const LoginPage(),
    );
  }
}