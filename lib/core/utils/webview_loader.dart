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
    final isAsset = embedUrl.startsWith('assets/');
    final uri = Uri.parse(embedUrl);
    final videoId = uri.queryParameters['id'];

    late final PlatformWebViewControllerCreationParams params;
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
      ..setNavigationDelegate(navigationDelegate);

    if (isAsset) {
      final assetPath = embedUrl.split('?')[0];
      final htmlString = await rootBundle.loadString(assetPath);
      final assetUrl = Uri.dataFromString(
        htmlString,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ).toString();
      final idParam = videoId != null ? '?id=$videoId' : '';
      await controller.loadRequest(Uri.parse('$assetUrl$idParam'));
    } else {
      await controller.loadRequest(Uri.parse(embedUrl));
    }

    if (controller.platform is AndroidWebViewController) {
      await AndroidWebViewController.enableDebugging(true);
      final androidController = controller.platform as AndroidWebViewController;
      await androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    return controller;
  }
}
