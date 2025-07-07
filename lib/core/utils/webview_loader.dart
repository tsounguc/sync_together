import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebviewLoader {
  static Future<WebViewController> create({
    required String embedUrl,
    required NavigationDelegate navigationDelegate,
    void Function()? onUserTappedPlay,
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
      ..addJavaScriptChannel(
        'PlayerEvent',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('[PlayerEvent]: ${message.message}');
          if (message.message == 'userPlayed') {
            onUserTappedPlay?.call();
          }
        },
      )
      ..loadRequest(Uri.parse(embedUrl));

    controller.runJavaScript('''
      function waitForYouTubePlayer() {
        if (typeof YT !== 'undefined' && YT.Player && player) {
          player.addEventListener('onStateChange', function(event) {
            if (event.data == YT.PlayerState.PLAYING) {
              PlayerEvent.postMessage('userPlayed');
            }
          });
        } else {
          setTimeout(waitForYouTubePlayer, 200);
        }
      }
      waitForYouTubePlayer();
    ''');

    // Enable autoplay for Android
    if (controller.platform is AndroidWebViewController) {
      await AndroidWebViewController.enableDebugging(true);
      final androidController = controller.platform as AndroidWebViewController;
      await androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    return controller;
  }
}
