import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_location/auth/auth_bloc.dart';
import 'package:tracker_location/auth/auth_event.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home - Solo Usuarios Azure')),
      body: Center(
        child: Column(
          children: [
            Text('Bienvenido! Estás autenticado.'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<AuthBloc>(context).add(LogoutEvent());
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}