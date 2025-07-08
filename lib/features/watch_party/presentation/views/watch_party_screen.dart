import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/views/watch_party_native_app_mode.dart';
import 'package:sync_together/features/watch_party/presentation/views/watch_party_web_sync_overlay.dart';
import 'package:sync_together/features/watch_party/presentation/views/watch_party_webview.dart';
import 'package:sync_together/themes/app_theme.dart';

class WatchPartyScreen extends StatefulWidget {
  const WatchPartyScreen({
    required this.watchParty,
    required this.platform,
    super.key,
  });

  final WatchParty watchParty;
  final StreamingPlatform platform;

  static const String id = '/watch-party';

  @override
  State<WatchPartyScreen> createState() => _WatchPartyScreenState();
}

class _WatchPartyScreenState extends State<WatchPartyScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDRMProtected = widget.platform.isDRMProtected;
    Widget watchView;
    if (kIsWeb) {
      watchView = WatchPartyWebSyncOverlay(
        watchParty: widget.watchParty,
        platform: widget.platform,
      );
    } else {
      if (isDRMProtected) {
        watchView = WatchPartyNativeAppMode(
          watchParty: widget.watchParty,
          platform: widget.platform,
        );
      } else {
        watchView = WatchPartyWebView(
          watchParty: widget.watchParty,
        );
      }
    }
    return Theme(
      data: AppTheme.darkTheme.copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          body: watchView,
        ),
      ),
    );
  }
}
