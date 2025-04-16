import 'package:android_intent_plus/android_intent.dart';
// import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NativeAppLauncher {
  static Future<void> openApp(String packageName) async {
    final intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.LAUNCHER',
      package: packageName,
      flags: <int>[268435456],
    );

    try {
      await intent.launch();
    } catch (e) {
      debugPrint('Could not launch app: $e');
    }
  }

  static Future<bool> isAppInstalled(String packageName) async {
    // try {
    //   return await DeviceApps.isAppInstalled(packageName);
    // } catch (e) {
    //   debugPrint('DeviceApp error: $e');
    //   return false;
    // }
    final intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.LAUNCHER',
      package: packageName,
    );
    return await intent.canResolveActivity() ?? false;
  }

  static Future<void> launchUri(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (!launched) {
        debugPrint('Could not launch Url via external app');
      }
    } else {
      debugPrint('Could not launch $url');
    }
  }

  static Future<void> launchUriScheme(String uri, String packageName) async {
    final intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.LAUNCHER',
      data: uri,
      package: packageName,
      flags: <int>[268435456],
    );
    try {
      await intent.launch();
    } catch (e) {
      debugPrint('Could not launch scheme intent: $e');
    }
  }
}
