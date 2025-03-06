import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sync_together/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:sync_together/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:sync_together/features/auth/domain/repositories/auth_repository.dart';
import 'package:sync_together/features/auth/domain/use_cases/get_current_user.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_anonymously.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_with_email.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_out.dart';
import 'package:sync_together/features/auth/domain/use_cases/sign_up_with_email.dart';
import 'package:sync_together/features/auth/presentation/auth_bloc/auth_bloc.dart';

part 'service_locator.main.dart';
