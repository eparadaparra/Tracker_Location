import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ Para que HomePage pueda leer el usuario logeado
  User? get currentUser => _auth.currentUser;

  /// ✅ Login Microsoft corporativo (single-tenant)
  Future<UserCredential> signInWithMicrosoft() async {
    final provider = OAuthProvider("microsoft.com");

    provider.addScope('openid');
    provider.addScope('profile');
    provider.addScope('email');

    // ✅ Forzar tenant corporativo
    provider.setCustomParameters({
      'tenant': '3cefa493-6a5c-47ee-9b55-fdad8535b58b',
      'prompt': 'select_account', // fuerza UI de cuenta, reduce estados raros
    });

    try {
      return await _auth
          .signInWithProvider(provider)
          .timeout(const Duration(seconds: 60));
    } on TimeoutException {
      throw Exception('Tiempo de espera en inicio de sesión. Cierra el navegador y reintenta.');
    }
      // provider.setCustomParameters({
      //   'tenant': '3cefa493-6a5c-47ee-9b55-fdad8535b58b',
      // });
      // return await _auth.signInWithProvider(provider);
  }
  
  /// ✅ Para que HomePage pueda cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}