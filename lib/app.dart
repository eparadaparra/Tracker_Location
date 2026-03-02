import 'package:flutter/material.dart';
import 'ui/ui.dart';

class TrackerApp extends StatelessWidget {
  const TrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracker',
      theme: ThemeData(useMaterial3: true),
      home: const LoginPage(),
    );
  }
}