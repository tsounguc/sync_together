// lib/features/watch_party/presentation/views/create_room_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/i_field.dart';
import 'package:sync_together/core/router/app_router.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/views/room_lobby_screen.dart';
import 'package:sync_together/features/watch_party/presentation/views/watch_party_screen.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_bloc/watch_party_bloc.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({required this.selectedPlatform, super.key});

  final StreamingPlatform selectedPlatform;

  static const String id = '/create-room';

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  bool _isPrivate = false;

  void _createRoom() {
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and video URL')),
      );
      return;
    }

    final newRoom = WatchPartyModel(
      id: '',
      title: title,
      videoUrl: url,
      platform: widget.selectedPlatform,
      createdAt: DateTime.now(),
      isPrivate: _isPrivate,
      hostId: context.currentUser!.uid,
      participantIds: [context.currentUser!.uid],
      lastSyncedTime: DateTime.now(),
      playbackPosition: 0,
      isPlaying: false,
      hasStarted: false,
    );

    context.read<WatchPartyBloc>().add(
          CreateWatchPartyEvent(
            party: newRoom,
            onSuccess: (createdParty) {},
            onFailure: (message) {},
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Watch Party Room'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Display selected platform
            Row(
              children: [
                Image.asset(widget.selectedPlatform.logoPath,
                    width: 32,
                    height: 32,
                    color: widget.selectedPlatform.logoPath.contains('disney') &&
                            Theme.of(
                                  context,
                                ).brightness ==
                                Brightness.dark
                        ? Colors.white
                        : null),
                const SizedBox(width: 12),
                Text(widget.selectedPlatform.name),
              ],
            ),
            const SizedBox(height: 20),
            IField(
              controller: _titleController,
              hintText: 'Room Title',
            ),

            const SizedBox(height: 16),
            if (widget.selectedPlatform.isDRMProtected)
              Text('Make sure everyone opens the '
                  'same movie in ${widget.selectedPlatform.name}')
            else
              IField(
                controller: _urlController,
                hintText: 'Streaming Video URL',
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Private Room'),
                const SizedBox(width: 10),
                Switch(
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            BlocConsumer<WatchPartyBloc, WatchPartyState>(
              listener: (context, state) {
                if (state is WatchPartyCreated) {
                  // Navigator.pushReplacementNamed(context, WatchPartyScreen.id,
                  //     arguments: WatchPartyScreenArguments(state.watchParty, widget.selectedPlatform));
                  Navigator.pushReplacementNamed(
                    context,
                    RoomLobbyScreen.id,
                    arguments: state.party,
                  );
                }
                if (state is WatchPartyError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                return state is WatchPartyLoading
                    ? const Column(
                        children: [
                          CircularProgressIndicator(),
                        ],
                      )
                    : ElevatedButton.icon(
                        onPressed: _createRoom,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Room'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                      );
              },
            )
          ],
        ),
      ),
    );
  }
}
