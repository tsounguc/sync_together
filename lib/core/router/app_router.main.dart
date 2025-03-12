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
                isAnonymous: user.isAnonymous,
              );

              context.userProvider.initUser(localUser);
              return const HomeScreen();
            }
            return const LoginScreen();
          },
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
          (_) => const HomeScreen(),
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
