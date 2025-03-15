import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sync_together/core/enums/update_user_action.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/utils/firebase_constants.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';

/// **Remote Data Source for Authentication**
///
/// Handles Firebase authentication logic.
abstract class AuthRemoteDataSource {
  /// Signs up a user with **email and password**.
  ///
  /// - **Success:** Returns a [UserModel].
  /// - **Failure:** Throws a [SignUpException].
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  /// Signs in a user with **email and password**.
  ///
  /// - **Success:** Returns a [UserModel].
  /// - **Failure:** Throws a [SignInException].
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });

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

  /// Send email to user to resent password.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws an [AuthException].
  Future<void> forgotPassword({required String email});

  /// Updates the **currently authenticated user** data.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws an [AuthException].
  Future<void> updateUserProfile({
    required UpdateUserAction action,
    required dynamic userData,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(
    this.firebaseAuth,
    this.firestore,
    this.firebaseStorage,
    this.googleSignIn,
  );

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final FirebaseStorage firebaseStorage;
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
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      // get user data from firestore with user uid
      var userData = await _getUserData(user!.uid);
      var userModel = const UserModel.empty();
      if (!userData.exists) {
        // if user doesn't have data in firestore
        // upload data to firestore
        await _setUserData(
          user,
          email,
        );

        // get user data from firestore with user uid
        userData = await _getUserData(user.uid);
        userModel = UserModel.fromMap(userData.data()!);
      } else {
        userModel = UserModel.fromMap(userData.data()!);
      }

      return userModel;
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
        throw const SignInException(
          message: 'Google sign-in aborted',
          statusCode: 'SIGN_IN_ABORTED',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
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
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
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

      await user.updateDisplayName(name);

      await _setUserData(
        firebaseAuth.currentUser,
        email,
      );

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

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ForgotPasswordException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw ForgotPasswordException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<void> updateUserProfile({
    required UpdateUserAction action,
    required dynamic userData,
  }) async {
    try {
      switch (action) {
        case UpdateUserAction.displayName:
          await firebaseAuth.currentUser?.updateDisplayName(
            userData as String,
          );
          await _updateUserData({'displayName': userData});

        case UpdateUserAction.email:
          final email = (userData as Map<String, dynamic>)['email'];
          final password = userData['password'];
          await firebaseAuth.currentUser?.reauthenticateWithCredential(
            EmailAuthProvider.credential(
              email: firebaseAuth.currentUser!.email!,
              password: password as String,
            ),
          );
          await firebaseAuth.currentUser?.verifyBeforeUpdateEmail(
            email as String,
          );
          await _updateUserData({'email': email});

        case UpdateUserAction.photoUrl:
          final image = (userData as Map<String, dynamic>)['image'];
          final password = userData['password'];

          await firebaseAuth.currentUser?.reauthenticateWithCredential(
            EmailAuthProvider.credential(
              email: firebaseAuth.currentUser!.email!,
              password: password as String,
            ),
          );
          final ref = firebaseStorage.ref().child('profile_pics/${firebaseAuth.currentUser?.uid}');
          final uploadTask = ref.putFile(image as File);

          // wait for upload completion
          final snapshot = await uploadTask.whenComplete(() => null);

          if (snapshot.state == TaskState.success) {
            final url = await ref.getDownloadURL();

            await firebaseAuth.currentUser?.updatePhotoURL(url);

            await _updateUserData({'photoUrl': url});
          } else {
            throw const UpdateUserException(
              message: 'Profile picture upload failed',
              statusCode: 'UPLOAD_FAILED',
            );
          }

        case UpdateUserAction.password:
          // this case is when user is already logged in
          // and is trying to change password in user settings
          final newData = jsonDecode(userData as String) as DataMap;
          if (firebaseAuth.currentUser?.email == null) {
            throw const UpdateUserException(
              message: 'User does not exist',
              statusCode: 'Insufficient Permission',
            );
          }
          await firebaseAuth.currentUser?.reauthenticateWithCredential(
            EmailAuthProvider.credential(
              email: firebaseAuth.currentUser!.email!,
              password: newData['oldPassword'] as String,
            ),
          );
          await firebaseAuth.currentUser?.updatePassword(
            newData['newPassword'] as String,
          );
      }
      // await firebaseAuth.currentUser?.reload();
    } on FirebaseAuthException catch (e) {
      throw UpdateUserException(
        message: e.message ?? 'User update failed',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw UpdateUserException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  Future<void> _updateUserData(DataMap data) async {
    await _users
        .doc(
          firebaseAuth.currentUser?.uid,
        )
        .update(data);
  }

  Future<DocumentSnapshot<DataMap>> _getUserData(String uid) async {
    return _users.doc(uid).get();
  }

  Future<void> _setUserData(User? user, String fallbackEmail) async {
    await _users.doc(user?.uid).set(
          const UserModel.empty()
              .copyWith(
                uid: user?.uid ?? '',
                displayName: user?.displayName ?? '',
                email: user?.email ?? fallbackEmail,
                photoUrl: user?.photoURL,
                isAnonymous: user?.isAnonymous,
              )
              .toMap(),
        );
  }

  CollectionReference<DataMap> get _users => firestore.collection(
        FirebaseConstants.usersCollection,
      );
}
