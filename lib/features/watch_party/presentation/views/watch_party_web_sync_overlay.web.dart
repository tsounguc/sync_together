import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/features/chat/presentation/chat_cubit/chat_cubit.dart';
import 'package:sync_together/features/chat/presentation/widgets/watch_party_chat.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';
import 'package:sync_together/features/watch_party/presentation/widgets/sync_controls_bar.dart';
import 'package:web/web.dart' as web;

class WatchPartyWebSyncOverlay extends StatefulWidget {
  const WatchPartyWebSyncOverlay({
    required this.watchParty,
    required this.platform,
    super.key,
  });

  final WatchParty watchParty;
  final StreamingPlatform platform;

  @override
  State<WatchPartyWebSyncOverlay> createState() => _WatchPartyWebSyncOverlayState();
}

class _WatchPartyWebSyncOverlayState extends State<WatchPartyWebSyncOverlay> {
  bool _hasLaunched = false;
  bool _popupBlocked = false;
  bool _showParticipants = true;

  web.Window? _streamingWindowRef;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _openSideBySideLayout();
        final partyId = widget.watchParty.id;
        context.read<ChatCubit>().listenToMessagesStream(partyId);
      },
    );

    final bloc = context.read<WatchPartySessionBloc>();
    web.window.onMessage.listen((event) {
      final data = event.data;
      // if (data is String) {
      debugPrint('Received message from streaming window: $data');
      // TODO(Web-Sync-Overlay): Handle specific commands
      // }
    });
    bloc.add(ListenToParticipantsEvent(widget.watchParty.id));
  }

  void _openSideBySideLayout() {
    if (_hasLaunched) return;
    _hasLaunched = true;

    final screenWidth = web.window.screen.width;
    final screenHeight = web.window.screen.height;

    final overlayWidth = (screenWidth / 3).floor();
    final streamingWidth = (screenWidth * 2 / 3).floor();
    const top = 0;

    // Resize this window (main app overlay)
    web.window.moveTo(0, top);
    web.window.resizeTo(overlayWidth, screenHeight);

    // Open streaming window
    final url = widget.watchParty.videoUrl.isNotEmpty ? widget.watchParty.videoUrl : widget.platform.defaultUrl;
    final uri = url.startsWith('http') ? url : 'https://$url';

    final features = 'width=$streamingWidth,height=$screenHeight,'
        'left=$overlayWidth,top=$top';

    final newWindow = web.window.open(uri, '_streamingWindow', features);

    if (newWindow == null) {
      setState(() {
        _popupBlocked = true;
      });
    } else {
      _streamingWindowRef = newWindow;
    }
  }

  void _reopenStreamingWindow() {
    setState(() {
      _popupBlocked = false;
    });
    _hasLaunched = false;
    _openSideBySideLayout();
  }

  void _sendMessageToStreamingWindow(String message) {
    if (_streamingWindowRef != null) {
      _streamingWindowRef!.postMessage(message.toJS, '*'.toJS);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHost = context.currentUser?.uid == widget.watchParty.hostId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.watchParty.title),
        actions: [
          if (_popupBlocked)
            TextButton.icon(
              onPressed: _reopenStreamingWindow,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Open Video',
                style: TextStyle(color: Colors.white),
              ),
            ),
          TextButton.icon(
            onPressed: () => _sendMessageToStreamingWindow('Hello from overlay'),
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text('Ping Video', style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            onPressed: () => setState(() => _showParticipants = !_showParticipants),
            icon: Icon(
              _showParticipants ? Icons.people : Icons.people_alt_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_popupBlocked)
            Container(
              color: Colors.amber.shade700,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.black),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your browser blocked the streaming window. Please allow popups or click "Open Video" above.',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          if (_showParticipants)
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Participants',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // You’ll later replace this with a BlocBuilder of ParticipantsUpdated
                    Expanded(
                      child: BlocBuilder<WatchPartySessionBloc, WatchPartySessionState>(
                        builder: (context, state) {
                          if (state is ParticipantsProfilesUpdated) {
                            final participants = state.profiles;
                            if (participants.isEmpty) {
                              return const Center(
                                child: Text('No Participants yet.'),
                              );
                            }

                            return ListView.separated(
                              itemCount: participants.length,
                              itemBuilder: (context, index) {
                                final user = participants[index];
                                final isYou = user.uid == context.currentUser!.uid;
                                return Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 16,
                                      child: Icon(Icons.person, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        isYou ? '${user.displayName} (You)' : user.displayName ?? 'Anonymous',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (_, __) => const Divider(
                                height: 16,
                              ),
                            );
                          }

                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sync & Chat',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SyncControlsBar(
                    partyId: widget.watchParty.id,
                    isHost: isHost,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: WatchPartyChat(partyId: widget.watchParty.id),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
