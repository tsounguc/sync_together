import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this.firebaseAuth, this.googleSignIn);

  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isAnonymous: user.isAnonymous,
    );
  }

  @override
  Future<UserModel> signInAnonymously() async {
    try {
      final userCredential = await firebaseAuth.signInAnonymously();
      final user = userCredential.user;
      if (user == null) {
        throw const SignInException(
          message: 'Anonymous sign-in failed',
          statusCode: 'USER_NULL',
        );
      }
      return UserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        isAnonymous: user.isAnonymous,
      );
    } on FirebaseAuthException catch (e) {
      throw SignInException(
        message: e.message ?? 'Anonymous sign-in failed',
        statusCode: e.code,
      );
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw const SignInException(
          message: 'User sign-in failed',
          statusCode: 'USER_NULL',
        );
      }
      return UserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        isAnonymous: user.isAnonymous,
      );
    } on FirebaseAuthException catch (e) {
      throw SignInException(
        message: e.message ?? 'Sign-in failed',
        statusCode: e.code,
      );
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw SignInException(
          message: 'Google sign-in aborted',
          statusCode: 'SIGN_IN_ABORTED',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw const SignInException(
          message: 'Google sign-in failed',
          statusCode: 'USER_NULL',
        );
      }

      return UserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        isAnonymous: user.isAnonymous,
      );
    } on FirebaseAuthException catch (e) {
      throw SignInException(
        message: e.message ?? 'Google sign-in failed',
        statusCode: e.code,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw SignOutException(
        message: e.message ?? 'Sign-out failed',
        statusCode: e.code,
      );
    }
  }

  @override
  Future<UserModel> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw const SignUpException(
          message: 'User creation failed',
          statusCode: 'USER_NULL',
        );
      }
      return UserModel(
        uid: user.uid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoURL,
        isAnonymous: user.isAnonymous,
      );
    } on FirebaseAuthException catch (e) {
      throw SignUpException(
        message: e.message ?? 'Sign-up failed',
        statusCode: e.code,
      );
    }
  }
}
