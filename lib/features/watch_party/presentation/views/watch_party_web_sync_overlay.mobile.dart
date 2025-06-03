import 'package:flutter/material.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';

class WatchPartyWebSyncOverlay extends StatelessWidget {
  const WatchPartyWebSyncOverlay({
    required this.watchParty,
    required this.platform,
    super.key,
  });

  final WatchParty watchParty;
  final StreamingPlatform platform;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('This feature is only available on web.'),
      ),
    );
  }
}
