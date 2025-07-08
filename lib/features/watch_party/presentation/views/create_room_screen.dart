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
      CoreUtils.showSnackBar(context, 'Please enter a title');
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
              Navigator.popUntil(context, ModalRoute.withName('/'));
              Navigator.pushNamed(
                context,
                RoomLobbyScreen.id,
                arguments: createdParty,
              );
            },
            onFailure: (message) => CoreUtils.showSnackBar(context, message),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final platform = widget.selectedPlatform;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Watch Party'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// Platform Info Header
              Row(
                children: [
                  Image.asset(
                    isDark && !platform.logoPath.contains('disney')
                        ? platform.logoDarkPath
                        : platform.logoPath,
                    width: 32,
                    height: 32,
                    color: isDark && platform.logoPath.contains('disney')
                        ? Colors.white
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    platform.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// Room Title Input
              IField(
                controller: _titleController,
                hintText: 'Room Title',
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 20),

              /// URL Section (if allowed)
              if (!platform.isDRMProtected)
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
                      'Or leave empty and pick the video later.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'This platform is DRM protected.\nEveryone must open the same video manually.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),

              const SizedBox(height: 24),

              /// Privacy Switch
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Private Room',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Switch(
                      value: _isPrivate,
                      onChanged: (value) => setState(() => _isPrivate = value),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// Create Button
              BlocConsumer<WatchPartySessionBloc, WatchPartySessionState>(
                listener: (context, state) {
                  if (state is WatchPartyError) {
                    CoreUtils.showSnackBar(context, state.message);
                  }
                },
                builder: (context, state) {
                  return state is WatchPartyLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _onCreateRoomPressed,
                            icon: const Icon(Icons.add),
                            label: const Text('Create Room'),
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
