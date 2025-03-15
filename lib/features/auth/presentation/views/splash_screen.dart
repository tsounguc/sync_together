import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:sync_together/features/auth/presentation/views/home_screen.dart';
import 'package:sync_together/features/auth/presentation/views/login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  static const String id = '/';

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        debugPrint('SplashScreen Current state: $state');
        if (state is Authenticated) {
          debugPrint('User is authenticated: Navigating to HomeScreen');
          Navigator.pushReplacementNamed(context, HomeScreen.id);
        } else {
          debugPrint('User is NOT authenticated: Navigating to LoginScreen');
          Navigator.pushReplacementNamed(context, LoginScreen.id);
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
