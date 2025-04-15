import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';
import 'package:sync_together/features/platforms/domain/use_cases/load_platforms.dart';

part 'platforms_state.dart';

class PlatformsCubit extends Cubit<PlatformsState> {
  PlatformsCubit(this._loadPlatforms) : super(PlatformsInitial());

  final LoadPlatforms _loadPlatforms;

  Future<void> fetchPlatforms() async {
    emit(PlatformsLoading());
    final result = await _loadPlatforms();
    result.fold(
      (failure) => emit(PlatformsError(failure.message)),
      (platforms) => emit(PlatformsLoaded(platforms)),
    );
  }
}
