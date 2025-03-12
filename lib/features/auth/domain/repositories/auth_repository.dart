import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';

/// **Authentication Repository Interface**
///
/// Defines the contract for authentication-related operations.
/// This allows the app to remain **independent of Firebase** or any other backend.
///
/// Each method **returns an Either type** (`ResultFuture<T>`),
/// ensuring that failures are handled explicitly instead of using exceptions.
abstract class AuthRepository {
  /// Signs up a user with **email and password**.
  ///
  /// - **Success:** Returns a [UserEntity] containing user details.
  /// - **Failure:** Returns an `AuthFailure` with an error message.
  ResultFuture<UserEntity> signUpWithEmail(
    String name,
    String email,
    String password,
  );

  /// Signs in a user with **email and password**.
  ///
  /// - **Success:** Returns a [UserEntity].
  /// - **Failure:** Returns an `AuthFailure`.
  ResultFuture<UserEntity> signInWithEmail(String email, String password);

  /// Signs in a user using **Google authentication**.
  ///
  /// - **Success:** Returns a [UserEntity].
  /// - **Failure:** Returns an `AuthFailure`.
  ResultFuture<UserEntity> signInWithGoogle();

  /// Signs in a user **anonymously** (no email/password required).
  ///
  /// - **Success:** Returns a [UserEntity].
  /// - **Failure:** Returns an `AuthFailure`.
  ResultFuture<UserEntity> signInAnonymously();

  /// Signs out the currently authenticated user.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns an `AuthFailure`.
  ResultVoid signOut();

  /// Retrieves the **currently authenticated user** (if any).
  ///
  /// - **Success:** Returns a [UserEntity], or `null` if no user is logged in.
  /// - **Failure:** Returns an `AuthFailure`
  ResultFuture<UserEntity?> getCurrentUser();

  /// Sends password reset email to email address
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns an `AuthFailure`.
  ResultVoid forgotPassword(String email);
}
