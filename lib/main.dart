import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_together/core/common/app/providers/greeting_provider.dart';
import 'package:sync_together/core/common/app/providers/theme_mode_provider.dart';
import 'package:sync_together/core/common/app/providers/user_provider.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/router/app_router.dart';
import 'package:sync_together/core/services/service_locator.dart';
import 'package:sync_together/features/auth/presentation/auth_bloc/auth_bloc.dart';
import 'package:sync_together/features/auth/presentation/views/splash_screen.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/watch_party_overlay.dart';
import 'package:sync_together/firebase_options.dart';
import 'package:sync_together/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpServices();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GreetingProvider(serviceLocator<SharedPreferences>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeModeProvider(serviceLocator<SharedPreferences>()),
        ),
      ],
      child: BlocProvider(
        create: (_) => serviceLocator<AuthBloc>()
          ..add(
            const GetCurrentUserEvent(),
          ),
        child: Builder(
          builder: (context) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Flutter Demo',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: context.watch<ThemeModeProvider>().themeMode,
              // initialRoute: SplashScreen.id,
              onGenerateRoute: AppRouter.onGenerateRoute,
            );
          },
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUpServices();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: BlocProvider(
        create: (_) => serviceLocator<AuthBloc>(),
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: OverlayEntryPoint(),
        ),
      ),
    ),
  );
}

class OverlayEntryPoint extends StatelessWidget {
  const OverlayEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Stack(
          children: [
            WatchPartyOverlay(
              watchPartyId: 'sample-party-id',
              onClose: FlutterOverlayWindow.closeOverlay,
              onPlay: () {},
              onPause: () {},
              onSync: () {},
            ),
          ],
        ),
      ),
    );
  }
}
