import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/resources/media_resources.dart';
import 'package:sync_together/core/resources/strings.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';
import 'package:sync_together/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:sync_together/features/auth/presentation/views/forgot_password_screen.dart';
import 'package:sync_together/features/auth/presentation/views/sign_up_screen.dart';
import 'package:sync_together/features/auth/presentation/views/splash_screen.dart';
import 'package:sync_together/features/auth/presentation/widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String id = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
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

  void _signInAnonymously(BuildContext context) {
    context.read<AuthBloc>().add(const SignInAnonymouslyEvent());
  }

  @override
  Widget build(BuildContext context) {
    final name = context.name;
    final greetingTop = name != null ? 'Welcome Back\n' : 'Welcome 👋\n';
    final greetingBottom =
        name != null ? _randomGreeting(name) : 'Let’s get you signed in.';

    final colorScheme = context.theme.colorScheme;
    final textColor = colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: Image.asset(
                  MediaResources.appLogo,
                  height: 120,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: greetingTop,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    TextSpan(
                      text: greetingBottom,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              LoginForm(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                onPasswordFieldSubmitted: (_) => _signIn(context),
              ),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) async {
                  if (state is Authenticated) {
                    if (mounted) {
                      await Navigator.pushReplacementNamed(
                        context,
                        SplashScreen.id,
                      );
                    }
                  } else if (state is AuthError) {
                    CoreUtils.showSnackBar(context, state.message);
                  }
                },
                builder: (context, state) {
                  return state is AuthLoading
                      ? const Center(child: CircularProgressIndicator())
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
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 100),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _signIn(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.login,
                                      color: colorScheme.onPrimary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Sign In',
                                      style: TextStyle(
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
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
                                    color: textColor,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: Strings.registerTextButtonText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.primary,
                                        decoration: TextDecoration.underline,
                                        decorationColor: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => _signInAnonymously(context),
                              child: Text(
                                'Continue as Guest',
                                style: TextStyle(
                                  color: colorScheme.outline,
                                  fontStyle: FontStyle.italic,
                                ),
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

  String _randomGreeting(String name) {
    final greetings = [
      'Good to see you again, $name 👋',
      'Glad to see you again, $name 👋',
      'Let’s jump back in, $name!',
    ];
    return greetings[Random().nextInt(greetings.length)];
  }
}
