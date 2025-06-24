import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/extensions/context_extension.dart';
import 'package:sync_together/core/i_field.dart';
import 'package:sync_together/core/utils/core_utils.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
import 'package:sync_together/features/watch_party/presentation/views/room_lobby_screen.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';

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

  void _onCreateRoomPressed() {
    final title = _titleController.text.trim();
    final url = _urlController.text.trim();

    if (title.isEmpty) {
      CoreUtils.showSnackBar(
        context,
        'Please enter a title',
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

    context.read<WatchPartySessionBloc>().add(
          CreateWatchPartyEvent(
            party: newRoom,
            onSuccess: (createdParty) {
              Navigator.popUntil(
                context,
                ModalRoute.withName('/'),
              );
              Navigator.pushNamed(
                context,
                RoomLobbyScreen.id,
                arguments: createdParty,
              );
            },
            onFailure: (message) => CoreUtils.showSnackBar(
              context,
              message,
            ),
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
                Image.asset(
                  widget.selectedPlatform.logoPath,
                  width: 32,
                  height: 32,
                  color: widget.selectedPlatform.logoPath.contains('disney') &&
                          Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : null,
                ),
                const SizedBox(width: 12),
                Text(widget.selectedPlatform.name),
              ],
            ),
            const SizedBox(height: 24),
            IField(
              controller: _titleController,
              hintText: 'Room Title',
            ),

            const SizedBox(height: 16),
            if (widget.selectedPlatform.isDRMProtected)
              Text(
                'This platform is DRM protected. '
                'Everyone must open the same video manually.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IField(
                    controller: _urlController,
                    hintText: 'Paste video URL (optional)',
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Or leave it empty and pick the video later.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
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
            BlocConsumer<WatchPartySessionBloc, WatchPartySessionState>(
              listener: (context, state) {
                if (state is WatchPartyError) {
                  CoreUtils.showSnackBar(
                    context,
                    state.message,
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
                        onPressed: _onCreateRoomPressed,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Room'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
