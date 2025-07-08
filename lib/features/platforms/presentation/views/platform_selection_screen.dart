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

class _PlatformSelectionScreenState extends State<PlatformSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    context.read<PlatformsCubit>().fetchPlatforms();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToCreateRoom(platform) {
    Navigator.pushNamed(
      context,
      CreateRoomScreen.id,
      arguments: platform,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎬 Choose a Platform'),
        centerTitle: true,
      ),
      body: BlocBuilder<PlatformsCubit, PlatformsState>(
        builder: (context, state) {
          if (state is PlatformsLoading) {
            return const PlatformShimmerGrid();
          }

          if (state is PlatformsError) {
            return Center(
              child: Text(
                state.message,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          if (state is PlatformsLoaded) {
            final platforms =
                state.platforms.where((p) => !p.isDRMProtected).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 5
                    : constraints.maxWidth > 600
                        ? 3
                        : 2;

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: platforms.length,
                      itemBuilder: (context, index) {
                        final platform = platforms[index];
                        return PlatformCard(
                          platform: platform,
                          onTap: () => _navigateToCreateRoom(platform),
                        );
                      },
                    ),
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
