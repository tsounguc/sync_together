import 'package:flutter/material.dart';
import 'package:sync_together/core/i_field.dart';
import 'package:sync_together/core/resources/strings.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    this.onPasswordFieldSubmitted,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final void Function(String)? onPasswordFieldSubmitted;
  final GlobalKey<FormState> formKey;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    const visible = Icons.visibility_outlined;
    const invisible = Icons.visibility_off_outlined;
    final icon = obscurePassword ? visible : invisible;
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          IField(
            controller: widget.emailController,
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            overrideValidator: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return Strings.emailRequiredText;
              } else if (!RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(value)) {
                return Strings.enterValidEmailText;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          IField(
            controller: widget.passwordController,
            hintText: 'Enter your password',
            obscureText: obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.send,
            onFieldSubmitted: widget.onPasswordFieldSubmitted,
            suffixIcon: IconButton(
              onPressed: () => setState(() {
                obscurePassword = !obscurePassword;
              }),
              icon: Icon(
                icon,
              ),
            ),
            overrideValidator: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return Strings.passwordRequiredText;
              } else if (value.length < 6) {
                return Strings.enterValidPasswordText;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
