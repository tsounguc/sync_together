import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/features/platforms/presentation/platforms_cubit/platforms_cubit.dart';
import 'package:sync_together/features/platforms/presentation/widgets/platform_card.dart';
import 'package:sync_together/features/platforms/presentation/widgets/platform_shimmer_grid.dart';
import 'package:sync_together/features/watch_party/presentation/views/create_room_screen.dart';

class PlatformSelectionScreen extends StatefulWidget {
  const PlatformSelectionScreen({super.key});

  static const String id = '/platform-selection-screen';

  @override
  State<PlatformSelectionScreen> createState() =>
      _PlatformSelectionScreenState();
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
      body: BlocBuilder<PlatformsCubit, PlatformsState>(
        builder: (context, state) {
          if (state is PlatformsLoading) {
            return const PlatformShimmerGrid();
          } else if (state is PlatformsError) {
            return Center(
              child: Text(state.message),
            );
          } else if (state is PlatformsLoaded) {
            final platforms = state.platforms
                .where((platform) => !platform.isDRMProtected)
                .toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 5
                    : constraints.maxWidth > 600
                        ? 3
                        : 2;
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: platforms.length,
                    itemBuilder: (context, index) {
                      final platform = platforms[index];
                      return PlatformCard(
                        platform: platform,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            CreateRoomScreen.id,
                            arguments: platform,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
