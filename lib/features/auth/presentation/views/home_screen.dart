import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:sync_together/features/auth/presentation/views/profile_screen.dart';
import 'package:sync_together/features/auth/presentation/views/splash_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String id = '/home';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        debugPrint('HomeScreen Current state: $state');
        if (state is AuthError) {
          CoreUtils.showSnackBar(context, state.message);
        }
        if (state is Unauthenticated) {
          debugPrint('Navigating back to login');
          context.userProvider.user = null;
          Navigator.of(context).pushNamedAndRemoveUntil(
            SplashScreen.id,
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        final user = context.userProvider.user;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                tooltip: 'Profile Settings',
                onPressed: () {
                  Navigator.pushNamed(context, ProfileScreen.id);
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(const SignOutEvent());
                },
              ),
            ],
          ),
          body: Center(
            child: Column(
              children: [
                const Text('Welcome to SyncTogether!'),
                Text(
                  user?.displayName ?? 'Guest',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (true == user?.isAnonymous)
                  ElevatedButton(
                    onPressed: () {
                      // TODO(HomeScreen): Implement linking account
                    },
                    child: const Text('Link Account'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
