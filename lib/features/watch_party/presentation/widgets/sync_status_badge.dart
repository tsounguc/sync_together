import 'package:flutter/material.dart';
import 'package:sync_together/core/enums/sync_status.dart';

/// **SyncStatusBadge**
///
/// Displays a dynamic badge to show current sync status to the guest user.
/// Automatically animates based on state.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({required this.status, super.key});

  final SyncStatus status;

  @override
  Widget build(BuildContext context) {
    final isSynced = status == SyncStatus.synced;
    final isError = status == SyncStatus.error;

    final color = isSynced
        ? Colors.green
        : isError
            ? Colors.red
            : Colors.orange;

    final icon = isSynced
        ? Icons.check_circle
        : isError
            ? Icons.warning_amber_rounded
            : Icons.sync;

    final label = isSynced
        ? 'Synced'
        : isError
            ? 'Error'
            : 'Syncing...';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
