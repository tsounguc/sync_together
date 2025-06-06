// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAcwDrQb6vpeSKSTY518_Zep2ayMSnorHs',
    appId: '1:706635927111:web:0574429d5f52dfb29eab62',
    messagingSenderId: '706635927111',
    projectId: 'synctogether-cf969',
    authDomain: 'synctogether-cf969.firebaseapp.com',
    storageBucket: 'synctogether-cf969.firebasestorage.app',
    measurementId: 'G-BL5557HQ1B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlGN7zwXEvSFZDXhxE_x1tXGQezYQ9QOI',
    appId: '1:706635927111:android:52156116a90056789eab62',
    messagingSenderId: '706635927111',
    projectId: 'synctogether-cf969',
    storageBucket: 'synctogether-cf969.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAWQxAewkzpcqyo3JF3lnEaIMXYdtYlk34',
    appId: '1:706635927111:ios:ac1fad286beff4349eab62',
    messagingSenderId: '706635927111',
    projectId: 'synctogether-cf969',
    storageBucket: 'synctogether-cf969.firebasestorage.app',
    iosClientId: '706635927111-6kc5v8tn7v3bn4mguvdsuu06ipqe25sq.apps.googleusercontent.com',
    iosBundleId: 'com.example.syncTogether',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAWQxAewkzpcqyo3JF3lnEaIMXYdtYlk34',
    appId: '1:706635927111:ios:ac1fad286beff4349eab62',
    messagingSenderId: '706635927111',
    projectId: 'synctogether-cf969',
    storageBucket: 'synctogether-cf969.firebasestorage.app',
    iosClientId: '706635927111-6kc5v8tn7v3bn4mguvdsuu06ipqe25sq.apps.googleusercontent.com',
    iosBundleId: 'com.example.syncTogether',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAcwDrQb6vpeSKSTY518_Zep2ayMSnorHs',
    appId: '1:706635927111:web:214ddaf5f58b66129eab62',
    messagingSenderId: '706635927111',
    projectId: 'synctogether-cf969',
    authDomain: 'synctogether-cf969.firebaseapp.com',
    storageBucket: 'synctogether-cf969.firebasestorage.app',
    measurementId: 'G-397KWLGCTM',
  );
}
