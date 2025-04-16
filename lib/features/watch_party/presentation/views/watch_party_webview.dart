import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/playback_controls.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WatchPartyWebView extends StatefulWidget {
  const WatchPartyWebView({
    required this.watchParty,
    super.key,
  });

  /// The Watch Party session details.
  final WatchParty watchParty;

  @override
  State<WatchPartyWebView> createState() => _WatchPartyWebViewState();
}

class _WatchPartyWebViewState extends State<WatchPartyWebView> {
  late WebViewController webViewController;
  int loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    // Ensure the URL has a valid scheme
    final validUrl = widget.watchParty.videoUrl.isEmpty
        ? widget.watchParty.platform.defaultUrl
        : widget.watchParty.videoUrl.startsWith('http')
            ? widget.watchParty.videoUrl
            : 'https://${widget.watchParty.videoUrl}';
    print(widget.watchParty.videoUrl);

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
            setState(() {
              loadingPercentage = 0;
            });
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            setState(() {
              loadingPercentage = 100;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
                Page resource error:
                code: ${error.errorCode}
                description: ${error.description}
                errorType: ${error.errorType}
                isForMainFrame: ${error.isForMainFrame}
                ''');
          },
          onNavigationRequest: (NavigationRequest navigationRequest) {
            debugPrint(navigationRequest.url);
            if (navigationRequest.url.contains('tel')) {
              launchUrl(
                Uri(
                  scheme: 'tel',
                  path: navigationRequest.url.substring(3),
                ),
              );
              debugPrint('blocking navigation to $navigationRequest}');
              return NavigationDecision.prevent;
            } else if (navigationRequest.url.contains('https://play.google.com/')) {
              if (Platform.isAndroid) {
                launchUrl(
                  Uri.parse(navigationRequest.url),
                  mode: LaunchMode.externalNonBrowserApplication,
                );
              } else {
                CoreUtils.showSnackBar(
                  context,
                  'Device does not support Google Play Store',
                );
              }
              debugPrint('blocking navigation to $navigationRequest}');
              return NavigationDecision.prevent;
            } else if (navigationRequest.url.contains('https://apps.apple.com/')) {
              if (Platform.isIOS) {
                launchUrl(
                  Uri.parse(navigationRequest.url),
                  mode: LaunchMode.externalNonBrowserApplication,
                );
              } else {
                CoreUtils.showSnackBar(
                  context,
                  'Device does not support App Store',
                );
              }
              debugPrint('blocking navigation to $navigationRequest}');
              return NavigationDecision.prevent;
            } else if (navigationRequest.url.contains('mailto')) {
              launchUrl(
                Uri.parse(navigationRequest.url),
                mode: LaunchMode.externalNonBrowserApplication,
              );
              debugPrint('blocking navigation to $navigationRequest}');
              return NavigationDecision.prevent;
            } else {
              debugPrint('allowing navigation to $navigationRequest');
              return NavigationDecision.navigate;
            }
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: openDialog,
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          CoreUtils.showSnackBar(
            context,
            message.message,
          );
        },
      )
      ..loadRequest(Uri.parse(validUrl));
    webViewController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.watchParty.title)),
      body: loadingPercentage < 100
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: loadingPercentage / 100,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  DefaultTextStyle(
                    style: TextStyle(
                      color: context.theme.iconTheme.color,
                      fontSize: 18,
                    ),
                    child: Text('Loading $loadingPercentage'),
                  ),
                ],
              ),
            )
          : WebViewWidget(
              controller: webViewController,
            ),
      bottomNavigationBar: WebPlaybackControls(
        controller: webViewController,
        watchPartyId: widget.watchParty.id,
      ),
    );
  }

  Future<void> openDialog(HttpAuthRequest httpRequest) async {
    final usernameTextController = TextEditingController();
    final passwordTextController = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${httpRequest.host}: ${httpRequest.realm ?? '-'}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  autofocus: true,
                  controller: usernameTextController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  controller: passwordTextController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // Explicitly cancel the request on iOS as the OS does not emit new
            // requests when a previous request is pending.
            TextButton(
              onPressed: () {
                httpRequest.onCancel();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                httpRequest.onProceed(
                  WebViewCredential(
                    user: usernameTextController.text,
                    password: passwordTextController.text,
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Authenticate'),
            ),
          ],
        );
      },
    );
  }
}
