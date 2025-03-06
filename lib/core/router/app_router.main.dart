part of 'app_router.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashScreen.id:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      // case AppRoutes.login:
      //   return MaterialPageRoute(builder: (_) => LoginScreen());
      // case AppRoutes.signup:
      //   return MaterialPageRoute(builder: (_) => SignUpScreen());
      // case AppRoutes.home:
      //   return MaterialPageRoute(builder: (_) => HomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
