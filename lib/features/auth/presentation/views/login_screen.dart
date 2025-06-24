import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/resources/strings.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:sync_together/features/auth/presentation/views/forgot_password_screen.dart';
import 'package:sync_together/features/auth/presentation/views/sign_up_screen.dart';
import 'package:sync_together/features/auth/presentation/views/splash_screen.dart';
import 'package:sync_together/features/auth/presentation/widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

  static const String id = '/login';
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _signIn(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            SignInWithEmailEvent(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  // void _signInWithGoogle(BuildContext context) {
  //   context.read<AuthBloc>().add(const SignInWithGoogleEvent());
  // }

  void _signInAnonymously(BuildContext context) {
    context.read<AuthBloc>().add(
          const SignInAnonymouslyEvent(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              LoginForm(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                onPasswordFieldSubmitted: (_) => _signIn(context),
              ),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  debugPrint('LoginScreen Current state: $state');
                  if (state is Authenticated) {
                    Navigator.pushReplacementNamed(context, SplashScreen.id);
                  }
                  if (state is AuthError) {
                    CoreUtils.showSnackBar(context, state.message);
                  }
                },
                builder: (context, state) {
                  return state is AuthLoading
                      ? const Column(
                          children: [
                            CircularProgressIndicator(),
                          ],
                        )
                      : Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    ForgotPasswordScreen.id,
                                  );
                                },
                                child: Text(
                                  Strings.forgotPasswordTextButtonText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: context.theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () => _signIn(
                                        context,
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 25,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  SignUpScreen.id,
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: Strings.dontHaveAccountText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.theme.textTheme.bodyMedium?.color,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: Strings.registerTextButtonText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blueAccent,
                                        decorationThickness: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => _signInAnonymously(context),
                              child: const Text(
                                'Continue as Guest',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
