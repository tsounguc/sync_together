import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';

/// **Remote Data Source for Authentication**
///
/// Handles Firebase authentication logic.
abstract class AuthRemoteDataSource {
  /// Signs up a user with **email and password**.
  ///
  /// - **Success:** Returns a [UserModel].
  /// - **Failure:** Throws a [SignUpException].
  Future<UserModel> signUpWithEmail(String email, String password);

  /// Signs in a user with **email and password**.
  ///
  /// - **Success:** Returns a [UserModel].
  /// - **Failure:** Throws a [SignInException].
  Future<UserModel> signInWithEmail(String email, String password);

  /// Signs in a user using **Google authentication**.
  ///
  /// - **Success:** Returns a [UserModel].
  /// - **Failure:** Throws a [SignInException].
  Future<UserModel> signInWithGoogle();

  /// Signs in a user **anonymously** (no email/password required).
  ///
  /// - **Success:** Returns a [UserModel].
  /// - **Failure:** Throws a [SignInException].
  Future<UserModel> signInAnonymously();

  /// Signs out the currently authenticated user.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws an [AuthException].
  Future<void> signOut();

  /// Retrieves the **currently authenticated user**.
  ///
  /// - **Success:** Returns a [UserModel], or `null` if no user is logged in.
  /// - **Failure:** Throws an [AuthException].
  Future<UserModel?> getCurrentUser();
}
