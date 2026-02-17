import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tracker_location/auth/auth_bloc.dart';
import 'package:tracker_location/auth/auth_state.dart';

import 'package:tracker_location/firebase_options.dart';

import 'screens/screens.dart';
import 'services/services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  MyApp() {
    // Inicializa el navigatorKey en config
    AzureAuthService.config.navigatorKey = navigatorKey;
  }

  Future<void> _requestPermissions() async {
  await Permission.location.request();
  await Permission.locationAlways.request();
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      initialNotificationTitle: "Seguimiento de ubicación",
      initialNotificationContent: "Enviando ubicación cada X minutos",
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true, 
      onForeground: onStart, 
      //onBackground: onStart
    ),
  );
  service.startService();
}

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return HomeScreen();
            } else {
              return LoginScreen();
            }
          },
        ),
      ),
    );
  }
}