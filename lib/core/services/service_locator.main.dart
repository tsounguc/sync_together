part of 'service_locator.dart';

final serviceLocator = GetIt.instance;

Future<void> setUpServices() async {
  await _initAuth();
  await _initFriend();
  await _initWatchParty();
  await _initPlatforms();
}

Future<void> _initPlatforms() async {
  serviceLocator
    // App Logic
    ..registerFactory(() => PlatformsCubit(serviceLocator()))
    // Use cases
    ..registerLazySingleton(() => LoadPlatforms(serviceLocator()))
    // Repositories
    ..registerLazySingleton<PlatformsRepository>(
      () => PlatformsRepositoryImpl(
        dataSource: serviceLocator(),
      ),
    )
    // Data sources
    ..registerLazySingleton<PlatformsDataSource>(
      () => PlatformsDataSourceImpl(),
    );
  //External Dependencies
}

Future<void> _initWatchParty() async {
  serviceLocator
    // App Logic
    ..registerFactory(
      () => WatchPartyBloc(
        createWatchParty: serviceLocator(),
        getWatchParty: serviceLocator(),
        joinWatchParty: serviceLocator(),
        syncPlayback: serviceLocator(),
        getSyncedData: serviceLocator(),
      ),
    )
    ..registerFactory(
      () => WatchPartyListCubit(serviceLocator()),
    )
    // Use cases
    ..registerLazySingleton(() => CreateWatchParty(serviceLocator()))
    ..registerLazySingleton(() => GetWatchParty(serviceLocator()))
    ..registerLazySingleton(() => JoinWatchParty(serviceLocator()))
    ..registerLazySingleton(() => SyncPlayback(serviceLocator()))
    ..registerLazySingleton(() => GetSyncedData(serviceLocator()))
    ..registerLazySingleton(() => GetPublicWatchParties(serviceLocator()))
    // Repositories
    ..registerLazySingleton<WatchPartyRepository>(
      () => WatchPartyRepositoryImpl(serviceLocator()),
    )
    ..registerLazySingleton<SyncPlaybackService>(
      () => WebRTCPlaybackSync(serviceLocator()),
    )
    // Data sources
    ..registerLazySingleton<WatchPartyRemoteDataSource>(
      () => WatchPartyRemoteDataSourceImpl(serviceLocator()),
    );
  //External Dependencies
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
