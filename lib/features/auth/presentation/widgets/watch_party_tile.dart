// watch_party_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';

class WatchPartyTile extends StatelessWidget {
  const WatchPartyTile({
    required this.party,
    required this.onPressed,
    super.key,
  });

  final WatchParty party;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<WatchPartySessionBloc, WatchPartySessionState>(
      buildWhen: (previous, current) =>
          current is UserLoaded && current.user.uid == party.hostId,
      builder: (context, state) {
        String hostName = 'Host';
        if (state is UserLoaded && state.user.uid == party.hostId) {
          hostName = state.user.displayName ?? 'Host';
        }

        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

          // elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            splashColor: colorScheme.primary.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Image.asset(
                    Theme.of(context).brightness == Brightness.dark &&
                            !party.platform.logoPath.contains('disney')
                        ? party.platform.logoDarkPath
                        : party.platform.logoPath,
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          party.title,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$hostName • ${party.platform.name} • ${party.participantIds.length} joined',
                          style: theme.textTheme.bodySmall
                          // ?.copyWith(color: colorScheme.outline,)
                          ,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
