import 'package:flutter/material.dart';
import 'package:sync_together/core/enums/sync_status.dart';

class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({required this.status, super.key});
  final SyncStatus status;
  @override
  Widget build(BuildContext context) {
    final isSynced = status == SyncStatus.synced;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isSynced ? Colors.green : Colors.orange,
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
          Icon(
            isSynced ? Icons.check_circle : Icons.sync,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            isSynced ? 'Synced' : 'Syncing...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
