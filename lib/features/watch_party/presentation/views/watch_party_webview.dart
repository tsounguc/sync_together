import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_bloc/watch_party_bloc.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/playback_controls.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WatchPartyWebView extends StatefulWidget {
  const WatchPartyWebView({
    required this.watchParty,
    super.key,
  });

  final WatchParty watchParty;

  @override
  State<WatchPartyWebView> createState() => _WatchPartyWebViewState();
}

class _WatchPartyWebViewState extends State<WatchPartyWebView> {
  late final WebViewController webViewController;
  int loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    context.read<WatchPartyBloc>().add(
          GetSyncedDataEvent(
            partyId: widget.watchParty.id,
          ),
        );
  }

  Future<void> _initializeWebView() async {
    final validUrl = widget.watchParty.videoUrl.isEmpty
        ? widget.watchParty.platform.defaultUrl
        : widget.watchParty.videoUrl.startsWith('http')
            ? widget.watchParty.videoUrl
            : 'https://${widget.watchParty.videoUrl}';

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
      ..setNavigationDelegate(_navigationDelegate)
      ..loadRequest(Uri.parse(validUrl));

    setState(() {
      webViewController = controller;
    });
  }

  NavigationDelegate get _navigationDelegate => NavigationDelegate(
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageStarted: (_) => setState(() => loadingPercentage = 0),
        onPageFinished: (_) => setState(() => loadingPercentage = 100),
        onNavigationRequest: (request) {
          if (_isExternalLink(request.url)) {
            _handleExternalLink(request.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      );

  bool _isExternalLink(String url) {
    return url.startsWith('tel') ||
        url.contains('play.google.com') ||
        url.contains('apps.apple.com') ||
        url.startsWith('mailto');
  }

  Future<void> _handleExternalLink(String url) async {
    try {
      if (url.startsWith('tel')) {
        await launchUrl(Uri(scheme: 'tel', path: url.substring(4)));
      } else if (url.contains('play.google.com') && Platform.isAndroid) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalNonBrowserApplication);
      } else if (url.contains('apps.apple.com') && Platform.isIOS) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalNonBrowserApplication);
      } else if (url.startsWith('mailto')) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalNonBrowserApplication);
      } else {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      CoreUtils.showSnackBar(context, 'Failed to open external link.');
    }
  }

  Future<void> _seekToPosition(double seconds) async {
    final jsCommand = """
      var video = document.querySelector('video');
      if (video) {
        video.currentTime = $seconds;
        video.play();
      }
    """;

    try {
      await webViewController.runJavaScript(jsCommand);
    } catch (e) {
      debugPrint('Error running JavaScript to seek video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WatchPartyBloc, WatchPartyState>(
      listener: (context, state) {
        if (state is SyncUpdated) {
          debugPrint('Sync update received:  position=${state.playbackPosition}');
          _seekToPosition(state.playbackPosition);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.watchParty.title)),
        body: loadingPercentage < 100
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(value: loadingPercentage / 100),
                    const SizedBox(height: 16),
                    Text('Loading... $loadingPercentage%'),
                  ],
                ),
              )
            : WebViewWidget(controller: webViewController),
        bottomNavigationBar: WebPlaybackControls(
          controller: webViewController,
          watchPartyId: widget.watchParty.id,
        ),
      ),
    );
  }
}
