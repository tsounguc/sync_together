import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sync_together/core/router/app_router.dart';
import 'package:sync_together/core/services/service_locator.dart';
import 'package:sync_together/features/auth/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await setUpServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
