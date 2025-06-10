part of 'app_router.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _pageBuilder(
          (context) {
            serviceLocator<FirebaseAuth>().currentUser?.reload();
            if (serviceLocator<FirebaseAuth>().currentUser != null) {
              final user = serviceLocator<FirebaseAuth>().currentUser!;

              final localUser = const UserModel.empty().copyWith(
                uid: user.uid,
                displayName: user.displayName,
                email: user.email,
                photoUrl: user.photoURL,
                isAnonymous: user.isAnonymous,
              );

              context.userProvider.initUser(localUser);
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => serviceLocator<WatchPartySessionBloc>(),
                  ),
                  BlocProvider(
                    create: (context) => serviceLocator<PublicPartiesCubit>(),
                  ),
                  BlocProvider(
                    create: (context) => serviceLocator<AuthBloc>(),
                  ),
                ],
                child: const HomeScreen(),
              );
            }
            return const LoginScreen();
          },
          settings: settings,
        );
      case ProfileScreen.id:
        return _pageBuilder(
          (_) => const ProfileScreen(),
          settings: settings,
        );
      case LoginScreen.id:
        return _pageBuilder(
          (_) => const LoginScreen(),
          settings: settings,
        );
      case SignUpScreen.id:
        return _pageBuilder(
          (_) => const SignUpScreen(),
          settings: settings,
        );
      case ForgotPasswordScreen.id:
        return _pageBuilder(
          (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case HomeScreen.id:
        return _pageBuilder(
          (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => serviceLocator<WatchPartySessionBloc>(),
              ),
              BlocProvider(
                create: (context) => serviceLocator<PublicPartiesCubit>(),
              ),
              BlocProvider(
                create: (context) => serviceLocator<AuthBloc>(),
              ),
            ],
            child: const HomeScreen(),
          ),
          settings: settings,
        );
      case PlatformSelectionScreen.id:
        return _pageBuilder(
          (_) => BlocProvider(
            create: (context) => serviceLocator<PlatformsCubit>(),
            child: const PlatformSelectionScreen(),
          ),
          settings: settings,
        );
      case CreateRoomScreen.id:
        final args = settings.arguments! as StreamingPlatform;
        return _pageBuilder(
          (_) => BlocProvider(
            create: (context) => serviceLocator<WatchPartySessionBloc>(),
            child: CreateRoomScreen(selectedPlatform: args),
          ),
          settings: settings,
        );
      case RoomLobbyScreen.id:
        final args = settings.arguments! as WatchParty;
        return _pageBuilder(
          (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => serviceLocator<WatchPartySessionBloc>(),
              ),
              BlocProvider(
                create: (context) => serviceLocator<ChatCubit>(),
              ),
            ],
            child: RoomLobbyScreen(
              watchParty: args,
            ),
          ),
          settings: settings,
        );
      case PlatformVideoPickerScreen.id:
        final args = settings.arguments! as PlatformVideoPickerScreenArgument;
        return _pageBuilder(
          (_) => BlocProvider(
            create: (context) => serviceLocator<WatchPartySessionBloc>(),
            child: PlatformVideoPickerScreen(
              watchParty: args.watchParty,
              platform: args.platform,
            ),
          ),
          settings: settings,
        );

      case WatchPartyScreen.id:
        final args = settings.arguments! as WatchPartyScreenArguments;
        return _pageBuilder(
          (_) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => serviceLocator<WatchPartySessionBloc>(),
              ),
              BlocProvider(
                create: (context) => serviceLocator<ChatCubit>(),
              ),
            ],
            child: WatchPartyScreen(
              watchParty: args.watchParty,
              platform: args.platform,
            ),
          ),
          settings: settings,
        );
      case FriendsScreen.id:
        return _pageBuilder(
          (_) => BlocProvider(
            create: (context) => serviceLocator<FriendsBloc>(),
            child: const FriendsScreen(),
          ),
          settings: settings,
        );
      case FriendRequestsScreen.id:
        return _pageBuilder(
          (_) => BlocProvider(
            create: (context) => serviceLocator<FriendsBloc>(),
            child: const FriendRequestsScreen(),
          ),
          settings: settings,
        );
      case FindFriendsScreen.id:
        return _pageBuilder(
          (_) => BlocProvider(
            create: (context) => serviceLocator<FriendsBloc>(),
            child: const FindFriendsScreen(),
          ),
          settings: settings,
        );
      default:
        return _pageBuilder(
          (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings: settings,
        );
    }
  }
}

PageRouteBuilder<dynamic> _pageBuilder(
  Widget Function(BuildContext context) page, {
  required RouteSettings settings,
}) {
  return PageRouteBuilder(
    settings: settings,
    transitionsBuilder: (_, animation, __, child) => FadeTransition(
      opacity: animation,
      child: child,
    ),
    pageBuilder: (context, _, __) => page(context),
  );
}

class WatchPartyScreenArguments {
  const WatchPartyScreenArguments(this.watchParty, this.platform);
  final WatchParty watchParty;
  final StreamingPlatform platform;
}

class PlatformVideoPickerScreenArgument {
  const PlatformVideoPickerScreenArgument({
    required this.watchParty,
    required this.platform,
  });
  final WatchParty watchParty;
  final StreamingPlatform platform;
}
