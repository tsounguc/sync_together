import 'package:flutter/material.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';

class PlatformCard extends StatelessWidget {
  const PlatformCard({
    super.key,
    required this.platform,
    required this.onTap,
  });

  final StreamingPlatform platform;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                platform.logoPath,
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                platform.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
