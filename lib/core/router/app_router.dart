import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/services/service_locator.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';
import 'package:sync_together/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:sync_together/features/auth/presentation/views/forgot_password_screen.dart';
import 'package:sync_together/features/auth/presentation/views/home_screen.dart';
import 'package:sync_together/features/auth/presentation/views/login_screen.dart';
import 'package:sync_together/features/auth/presentation/views/profile_screen.dart';
import 'package:sync_together/features/auth/presentation/views/sign_up_screen.dart';
import 'package:sync_together/features/auth/presentation/views/splash_screen.dart';

part 'app_router.main.dart';
