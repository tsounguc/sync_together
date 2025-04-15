import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/core/router/app_router.dart';
import 'package:sync_together/features/platforms/presentation/platforms_cubit/platforms_cubit.dart';
import 'package:sync_together/features/platforms/presentation/widgets/platform_card.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/presentation/views/watch_party_screen.dart';

class PlatformSelectionScreen extends StatefulWidget {
  const PlatformSelectionScreen({super.key});

  @override
  State<PlatformSelectionScreen> createState() => _PlatformSelectionScreenState();
}

class _PlatformSelectionScreenState extends State<PlatformSelectionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PlatformsCubit>().fetchPlatforms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Platform'),
      ),
      body: BlocBuilder<PlatformsCubit, PlatformsState>(builder: (context, state) {
        if (state is PlatformsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is PlatformsError) {
          return Center(
            child: Text(state.message),
          );
        } else if (state is PlatformsLoaded) {
          final platforms = state.platforms;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: platforms.length,
            itemBuilder: (context, index) {
              final platform = platforms[index];
              return PlatformCard(
                  platform: platform,
                  onTap: () {
                    final watchParty = WatchPartyModel.empty().copyWith(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: '${platform.name} Watch Party',
                      videoUrl: platform.defaultUrl,
                    );

                    Navigator.pushNamed(
                      context,
                      WatchPartyScreen.id,
                      arguments: WatchPartyScreenArguments(
                        watchParty,
                        platform,
                      ),
                    );
                  });
            },
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }
}
