import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/i_field.dart';
import 'package:sync_together/core/resources/strings.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:sync_together/features/auth/presentation/views/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const String id = '/forgotPasswordScreen';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Reset Password',
          style: TextStyle(
              // color: Colors.white,
              ),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (_, state) {
          if (state is AuthError) {
            CoreUtils.showSnackBar(context, state.message);
          } else if (state is ForgotPasswordSent) {
            CoreUtils.showSnackBar(
              context,
              Strings.forgotPasswordSnackBarMessage,
            );
            Navigator.pushReplacementNamed(
              context,
              LoginScreen.id,
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          state is ForgotPasswordSent ? Strings.passwordSentText : Strings.passwordNotSentText,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Visibility(
                    visible: state is! ForgotPasswordSent,
                    child: Form(
                      key: formKey,
                      child: IField(
                        controller: emailController,
                        hintText: Strings.emailHintText,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  if (state is AuthLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (state is! ForgotPasswordSent)
                    ElevatedButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        FirebaseAuth.instance.currentUser?.reload();
                        if (formKey.currentState!.validate()) {
                          context.read<AuthBloc>().add(
                                ForgotPasswordEvent(
                                  email: emailController.text.trim(),
                                ),
                              );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      child: const Text(
                        Strings.resetPasswordButtonText,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
