import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sync_together/core/enums/update_user_action.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/extensions/string_extensions.dart';
import 'package:sync_together/core/i_field.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';
import 'package:sync_together/features/auth/presentation/auth_bloc/auth_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String id = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();

  File? _selectedImage;

  bool get nameChanged => context.currentUser?.displayName?.trim() != _displayNameController.text.trim();

  bool get emailChanged => _emailController.text.trim().isNotEmpty;

  bool get imageChanged => _selectedImage != null;

  bool get nothingChanged => !nameChanged && !emailChanged && !imageChanged;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final bloc = context.read<AuthBloc>();
    if (nothingChanged) Navigator.pop(context);
    String? password;

    if (nameChanged) {
      bloc.add(
        UpdateUserProfileEvent(
          action: UpdateUserAction.displayName,
          userData: _displayNameController.text.trim(),
        ),
      );
    }
    if (emailChanged) {
      password = await _promptForPassword();
      if (password == null) return;
      bloc.add(
        UpdateUserProfileEvent(
          action: UpdateUserAction.email,
          userData: {
            'email': _emailController.text.trim(),
            'password': password,
          },
        ),
      );
    }
    if (imageChanged) {
      password = await _promptForPassword();
      if (password == null) return;
      bloc.add(
        UpdateUserProfileEvent(
          action: UpdateUserAction.photoUrl,
          userData: {
            'image': _selectedImage,
            'password': password,
          },
        ),
      );
    }
  }

  @override
  void initState() {
    // Fetch updated user profile when entering the screen
    _displayNameController.text = context.currentUser?.displayName?.trim() ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : context.currentUser?.photoUrl != null
                        ? NetworkImage(context.currentUser!.photoUrl!)
                        : null,
                child: _selectedImage == null && context.currentUser?.photoUrl == null
                    ? const Icon(Icons.camera_alt, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            IField(
              controller: _displayNameController,
              hintText: context.currentUser?.displayName,
              borderColor: Colors.transparent,
            ),
            IField(
              controller: _emailController,
              hintText: context.currentUser?.email?.obscureEmail,
              borderColor: Colors.transparent,
            ),
            const SizedBox(height: 20),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  context.userProvider.user = state.user as UserModel?;
                }
                if (state is UserProfileUpdated) {
                  CoreUtils.showSnackBar(
                    context,
                    'Profile Updated Successfully',
                  );
                  context.read<AuthBloc>().add(const GetCurrentUserEvent());
                } else if (state is AuthError) {
                  CoreUtils.showSnackBar(context, state.message);
                }
              },
              builder: (context, state) {
                return state is AuthLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _updateProfile,
                        child: const Text('Save Changes'),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _promptForPassword() async {
    final passwordController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-authenticate'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Enter your password',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, passwordController.text);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
