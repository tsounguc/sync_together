import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebviewLoader {
  static Future<WebViewController> create({
    required String embedUrl,
    required NavigationDelegate navigationDelegate,
  }) async {
    late final PlatformWebViewControllerCreationParams params;

    // Choose correct WebView implementation based on platform
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(navigationDelegate)
      ..loadRequest(Uri.parse(embedUrl));

    // Enable autoplay for Android
    if (controller.platform is AndroidWebViewController) {
      await AndroidWebViewController.enableDebugging(true);
      final androidController = controller.platform as AndroidWebViewController;
      await androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    return controller;
  }
}
