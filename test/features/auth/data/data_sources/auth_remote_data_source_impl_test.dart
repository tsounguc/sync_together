import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}

class MockAuthCredential extends Mock implements AuthCredential {}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockUser extends Mock implements User {
  @override
  String get uid => '12345';

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';

  @override
  String? get photoURL => 'https://placehold.co/600x400.png';

  @override
  bool get isAnonymous => false;
}

void main() {
  late FirebaseAuth firebaseAuth;
  late FirebaseFirestore firestore;
  late MockFirebaseStorage storage;
  late AuthRemoteDataSourceImpl remoteDataSourceImpl;
  late GoogleSignIn googleSignIn;
  late GoogleSignInAccount googleSignInAccount;
  late GoogleSignInAuthentication googleSignInAuthentication;
  late UserCredential userCredential;
  late MockUser user;

  setUpAll(() {
    firebaseAuth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    storage = MockFirebaseStorage();
    googleSignIn = MockGoogleSignIn();
    googleSignInAccount = MockGoogleSignInAccount();
    googleSignInAuthentication = MockGoogleSignInAuthentication();
    userCredential = MockUserCredential();
    user = MockUser();

    remoteDataSourceImpl = AuthRemoteDataSourceImpl(
      firebaseAuth,
      firestore,
      storage,
      googleSignIn,
    );

    registerFallbackValue(MockAuthCredential());
    registerFallbackValue(MockAuthProvider());

    // Mock Google Sign-In Flow
    when(() => googleSignIn.signIn()).thenAnswer((_) async => googleSignInAccount);
    when(() => googleSignInAccount.authentication).thenAnswer((_) async => googleSignInAuthentication);
    when(() => googleSignInAuthentication.accessToken).thenReturn('mock_access_token');
    when(() => googleSignInAuthentication.idToken).thenReturn('mock_id_token');

    // Mock Firebase Authentication with Google Credentials
    when(
      () => firebaseAuth.signInWithCredential(any()),
    ).thenAnswer((_) async => userCredential);
    // when(() => userCredential.user).thenReturn(user);
    when(
      () => firebaseAuth.signInWithPopup(any()),
    ).thenAnswer((_) async => userCredential);

    when(() => userCredential.user).thenReturn(user);
  });

  const name = 'name';
  const email = 'test@example.com';
  const password = 'password123';

  group('signUpWithEmail - ', () {
    test(
      'given AuthRemoDataSourceImpl '
      'when [FirebaseAuth.createUserWithEmailAndPassword] is called '
      'then return [UserModel]',
      () async {
        // Arrange
        when(
          () => firebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => userCredential);

        when(() => userCredential.user).thenReturn(user);

        // Act
        final result = await remoteDataSourceImpl.signUpWithEmail(
          name,
          email,
          password,
        );

        // Assert
        expect(result, isA<UserModel>());
        expect(result.uid, user.uid);
        verify(
          () => firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      },
    );

    test(
      'given AuthRemoDataSourceImpl '
      'when [FirebaseAuth.createUserWithEmailAndPassword] is called '
      'and [FirebaseAuthException] is thrown '
      'then throw [SignUpException]',
      () async {
        // Arrange
        final testException = FirebaseAuthException(
          message: 'Sign-up failed',
          code: 'sign-up-error',
        );
        when(
          () => firebaseAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(testException);

        // Act
        final methodCall = remoteDataSourceImpl.signUpWithEmail;

        // Assert
        expect(
          () => methodCall(name, email, password),
          throwsA(isA<SignUpException>()),
        );
      },
    );
  });

  group('signInWithEmail - ', () {
    test(
      'given AuthRemoDataSourceImpl '
      'when [FirebaseAuth.signInWithEmailAndPassword] is called '
      'then return [UserModel]',
      () async {
        // Arrange
        when(() => firebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => userCredential);

        when(() => userCredential.user).thenReturn(user);

        // Act
        final result = await remoteDataSourceImpl.signInWithEmail(email, password);

        // Assert
        expect(result, isA<UserModel>());
        expect(result.uid, user.uid);
        verify(
          () => firebaseAuth.signInWithEmailAndPassword(
            email: email,
            password: password,
          ),
        ).called(1);
      },
    );

    test(
      'given AuthRemoDataSourceImpl '
      'when [FirebaseAuth.signInWithEmailAndPassword] is called '
      'and [FirebaseAuthException] is thrown '
      'then throw [SignInException]',
      () async {
        // Arrange
        final testException = FirebaseAuthException(
          message: 'Sign-in failed',
          code: 'sign-in-error',
        );
        when(
          () => firebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(testException);

        // Act
        final methodCall = remoteDataSourceImpl.signInWithEmail;

        // Assert
        expect(
          () => methodCall(email, password),
          throwsA(isA<SignInException>()),
        );
      },
    );
  });

  group('signInWithGoogle - ', () {
    test(
      'given AuthRemoDataSourceImpl '
      'when [FirebaseAuth.signInWithGoogle] is called '
      'then return [UserModel]',
      () async {
        // Arrange

        // Act
        final result = await remoteDataSourceImpl.signInWithGoogle();

        // Assert
        expect(result, isA<UserModel>());
        expect(result.uid, user.uid);
        verify(() => firebaseAuth.signInWithCredential(any())).called(1);
      },
    );

    test(
      'given AuthRemoDataSourceImpl '
      'when [FirebaseAuth.signInWithGoogle] is called '
      'and [FirebaseAuthException] is thrown '
      'then throw [SignInException]',
      () async {
        // Arrange
        final testException = FirebaseAuthException(
          message: 'Google sign-in failed',
          code: 'google-sign-in-error',
        );
        when(
          () => firebaseAuth.signInWithCredential(any()),
        ).thenThrow(testException);

        // Act
        final methodCall = remoteDataSourceImpl.signInWithGoogle;
        // Assert
        expect(
          methodCall,
          throwsA(isA<SignInException>()),
        );
      },
    );
  });

  group('signInAnonymous - ', () {
    test(
      'given AuthRemoDataSourceImpl '
      'when [FirebaseAuth.signInAnonymously] is called '
      'then return [UserModel]',
      () async {
        // Arrange
        when(
          () => firebaseAuth.signInAnonymously(),
        ).thenAnswer((_) async => userCredential);

        when(
          () => userCredential.user,
        ).thenReturn(user);

        // Act
        final result = await remoteDataSourceImpl.signInAnonymously();

        // Assert
        expect(result, isA<UserModel>());
        expect(result.uid, user.uid);
        verify(() => firebaseAuth.signInAnonymously()).called(1);
      },
    );

    test(
      'given AuthRemoDataSourceImpl '
      'when [FirebaseAuth.signInAnonymously] is called '
      'and [FirebaseAuthException] is thrown '
      'then throw [SignInException]',
      () async {
        // Arrange
        when(() => firebaseAuth.signInAnonymously()).thenThrow(
          FirebaseAuthException(
            message: 'Anonymous sign-in failed',
            code: 'sign-in-error',
          ),
        );

        // Act
        final methodCall = remoteDataSourceImpl.signInAnonymously;

        // Assert
        expect(
          methodCall,
          throwsA(isA<SignInException>()),
        );
      },
    );
  });

  group('signOut - ', () {
    test(
      'given AuthRemoDataSourceImpl '
      'when [FirebaseAuth.signOut] is called '
      'then return [UserModel]',
      () async {
        // Arrange
        when(
          () => firebaseAuth.signOut(),
        ).thenAnswer((_) async => Future.value());

        // Act
        await remoteDataSourceImpl.signOut();

        // Assert
        verify(() => firebaseAuth.signOut()).called(1);
      },
    );

    test(
      'given AuthRemoDataSourceImpl '
      'when [FirebaseAuth.signOut] is called '
      'and [FirebaseAuthException] is thrown '
      'then throw [SignInException]',
      () async {
        // Arrange
        final testException = FirebaseAuthException(
          message: 'Sign-out failed',
          code: 'sign-out-error',
        );
        when(
          () => firebaseAuth.signOut(),
        ).thenThrow(testException);

        // Act
        final methodCall = remoteDataSourceImpl.signOut;

        // Assert
        expect(
          methodCall,
          throwsA(isA<AuthException>()),
        );
      },
    );
  });

  group('getCurrentUser - ', () {
    test(
        'given AuthRemoDataSourceImpl '
        'when [FirebaseAuth.currentUser] is called '
        'then return [UserModel]', () async {
      // Arrange
      when(() => firebaseAuth.currentUser).thenReturn(user);

      // Act
      final result = await remoteDataSourceImpl.getCurrentUser();

      // Assert
      expect(result, isA<UserModel>());
      expect(result?.uid, user.uid);
      verify(() => firebaseAuth.currentUser).called(1);
    });

    test(
      'given AuthRemoDataSourceImpl '
      'when [FirebaseAuth.currentUser] is called '
      'then return null',
      () async {
        // Arrange
        when(() => firebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await remoteDataSourceImpl.getCurrentUser();

        // Assert
        expect(result, isNull);
        verify(() => firebaseAuth.currentUser).called(1);
      },
    );
  });
}
