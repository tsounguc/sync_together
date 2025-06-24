import 'package:flutter/material.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';

class WatchPartyTile extends StatelessWidget {
  const WatchPartyTile({
    required this.party,
    required this.onPressed,
    super.key,
  });

  final WatchParty party;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[850] : Colors.grey[200];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Image.asset(
            party.platform.logoPath,
            width: 40,
            height: 40,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(party.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${party.platform.name} • ${party.participantIds.length} joined',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
