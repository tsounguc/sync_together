import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/i_field.dart';
import 'package:sync_together/core/resources/media_resources.dart';
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

  void _submit(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    FirebaseAuth.instance.currentUser?.reload();
    if (formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            ForgotPasswordEvent(
              email: emailController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.theme.colorScheme;
    final textColor = colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Reset Password'),
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
          final isSent = state is ForgotPasswordSent;
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Image.asset(
                    MediaResources.appLogo,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  isSent
                      ? Strings.passwordSentText
                      : Strings.passwordNotSentText,
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 24),
                if (!isSent)
                  Form(
                    key: formKey,
                    child: IField(
                      controller: emailController,
                      hintText: Strings.emailHintText,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                const SizedBox(height: 40),
                if (state is AuthLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (!isSent)
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: () => _submit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text(
                        Strings.resetPasswordButtonText,
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
