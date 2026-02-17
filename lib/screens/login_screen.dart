import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_location/auth/auth_bloc.dart';
import 'package:tracker_location/auth/auth_event.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.login),
          label: Text('Autenticar con cuenta de Execon'),
          onPressed: () {
            BlocProvider.of<AuthBloc>(context).add(LoginEvent());
          },
          
        ),
      ),
    );
  }
}