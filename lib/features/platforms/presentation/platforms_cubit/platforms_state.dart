part of 'platforms_cubit.dart';
abstract class PlatformsState extends Equatable {
  const PlatformsState();
  @override
  List<Object?> get props => [];
}

class PlatformsInitial extends PlatformsState {}

class PlatformsLoading extends PlatformsState {}

class PlatformsLoaded extends PlatformsState {
  const PlatformsLoaded(this.platforms);
  final List<StreamingPlatform> platforms;

  @override
  List<Object?> get props => [platforms];
}

class PlatformsError extends PlatformsState {
  const PlatformsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
