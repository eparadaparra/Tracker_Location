import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_location/auth/auth_event.dart';
import 'package:tracker_location/auth/auth_state.dart';
import 'package:tracker_location/services/azure_auth_service.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AzureAuthService authService = AzureAuthService();

  AuthBloc() : super(AuthInitial()) {
    
    on<LoginEvent>((event, emit) async {
      final token = await authService.login();
      if (token != null) {
        emit(AuthAuthenticated(token));
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<LogoutEvent>((event, emit) async {
      await authService.logout();
      emit(AuthUnauthenticated());
    });
  }
}