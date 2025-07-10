import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sync_together/features/watch_party/presentation/helpers/playback_controllers/playback_controller.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';

class SyncManager {
  SyncManager({
    required this.playback,
    required this.watchPartyId,
    required this.currentTimeScript,
    required this.bloc,
  });

  final PlaybackController playback;
  final String watchPartyId;
  final String currentTimeScript;
  final WatchPartySessionBloc bloc;

  Timer? _timer;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      try {
        if (!await playback.hasVideoTag()) return;
        final position = await playback.getCurrentTime(currentTimeScript);
        final isPlaying = await playback.isPlaying();

        debugPrint('[SyncManager]: video is playing: $isPlaying');
        bloc.add(SendSyncDataEvent(
          partyId: watchPartyId,
          playbackPosition: position,
          isPlaying: isPlaying,
        ));
      } catch (e) {
        // optionally log error
      }
    });
  }

  Future<void> stop() async {
    await playback.pause();
    _timer?.cancel();
    _timer = null;
  }
}
