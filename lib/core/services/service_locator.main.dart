part of 'service_locator.dart';

final serviceLocator = GetIt.instance;

Future<void> setUpServices() async {
  await _initAuth();
}

Future<void> _initAuth() async {
  serviceLocator
    ..registerFactory(
      () => AuthBloc(
        signInWithEmail: serviceLocator(),
        signInWithGoogle: serviceLocator(),
        signInAnonymously: serviceLocator(),
        signUpWithEmail: serviceLocator(),
        signOut: serviceLocator(),
        getCurrentUser: serviceLocator(),
      ),
    )
    ..registerLazySingleton(() => SignInWithEmail(serviceLocator()))
    ..registerLazySingleton(() => SignInWithGoogle(serviceLocator()))
    ..registerLazySingleton(() => SignInAnonymously(serviceLocator()))
    ..registerLazySingleton(() => SignUpWithEmail(serviceLocator()))
    ..registerLazySingleton(() => GetCurrentUser(serviceLocator()))
    ..registerLazySingleton(() => SignOut(serviceLocator()))
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator()),
    )
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => FirebaseAuth.instance,
    )
    ..registerLazySingleton(
      () => GoogleSignIn.new,
    );
}
