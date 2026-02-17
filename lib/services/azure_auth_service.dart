import 'package:flutter/material.dart';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';


class AzureAuthService {
  static final Config config = Config(
    tenant: '3cefa493-6a5c-47ee-9b55-fdad8535b58b',  // Tu Directory (tenant) ID
    clientId: '7a32364d-4c15-465b-b5cc-1d66e6a70637',  // Tu Application (client) ID
    scope: 'openid profile offline_access User.Read',  // Permisos necesarios
    redirectUri: 'msauth://com.example.infrastructure_execon/ODM6QTM6NzM6N0I6RDI6RTc6Q0E6OUE6NEE6NUY6Qzg6QUE6NDE6Q0Q6RDA6NEE6MTc6RDA6NTc6ODg6Rjk6N0M6QUM6Qzg6NTM6RDI6MEY6QUI6NkI6RjI6MjY6MUU',  // Usa tu redirect real del Paso 1
    navigatorKey: GlobalKey<NavigatorState>(),
    loader: const Center(child: CircularProgressIndicator()),
  );

  final AadOAuth oauth = AadOAuth(config);

  Future<String?> login() async {
    try {
      await oauth.login();
      return await oauth.getAccessToken();
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await oauth.logout();
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await oauth.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error al verificar token: $e');
      return false;
    }
  }
}