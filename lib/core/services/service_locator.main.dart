part of 'service_locator.dart';

final serviceLocator = GetIt.instance;

Future<void> setUpServices() async {
  await _initAuth();
  await _initFriend();
}

Future<void> _initFriend() async {
  serviceLocator
    // App Logic
    ..registerFactory(
      () => FriendBloc(
        sendFriendRequest: serviceLocator(),
        acceptFriendRequest: serviceLocator(),
        rejectFriendRequest: serviceLocator(),
        removeFriend: serviceLocator(),
        getFriends: serviceLocator(),
        getFriendRequests: serviceLocator(),
        searchUsers: serviceLocator(),
      ),
    )
    // Use cases
    ..registerLazySingleton(() => SendFriendRequest(serviceLocator()))
    ..registerLazySingleton(() => AcceptFriendRequest(serviceLocator()))
    ..registerLazySingleton(() => RejectFriendRequest(serviceLocator()))
    ..registerLazySingleton(() => RemoveFriend(serviceLocator()))
    ..registerLazySingleton(() => GetFriends(serviceLocator()))
    ..registerLazySingleton(() => GetFriendRequests(serviceLocator()))
    ..registerLazySingleton(() => SearchUsers(serviceLocator()))
    // Repositories
    ..registerLazySingleton<FriendRepository>(
      () => FriendRepositoryImpl(serviceLocator()),
    )
    // Data sources
    ..registerLazySingleton<FriendRemoteDataSource>(
      () => FriendRemoteDataSourceImpl(serviceLocator()),
    );
}

Future<void> _initAuth() async {
  serviceLocator
    // App Logic
    ..registerFactory(
      () => AuthBloc(
        signInWithEmail: serviceLocator(),
        signInWithGoogle: serviceLocator(),
        signInAnonymously: serviceLocator(),
        signUpWithEmail: serviceLocator(),
        signOut: serviceLocator(),
        getCurrentUser: serviceLocator(),
        forgotPassword: serviceLocator(),
        updateUser: serviceLocator(),
      ),
    )
    // Use cases
    ..registerLazySingleton(() => SignInWithEmail(serviceLocator()))
    ..registerLazySingleton(() => SignInWithGoogle(serviceLocator()))
    ..registerLazySingleton(() => SignInAnonymously(serviceLocator()))
    ..registerLazySingleton(() => SignUpWithEmail(serviceLocator()))
    ..registerLazySingleton(() => GetCurrentUser(serviceLocator()))
    ..registerLazySingleton(() => SignOut(serviceLocator()))
    ..registerLazySingleton(() => ForgotPassword(serviceLocator()))
    ..registerLazySingleton(() => UpdateUserProfile(serviceLocator()))

    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator()),
    )

    // Data Source
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
        serviceLocator(),
      ),
    )
    // External dependencies
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => FirebaseFirestore.instance)
    ..registerLazySingleton(() => FirebaseStorage.instance)
    ..registerLazySingleton(GoogleSignIn.new);
}
