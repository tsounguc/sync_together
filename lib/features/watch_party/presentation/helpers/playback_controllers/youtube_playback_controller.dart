import 'package:sync_together/features/watch_party/presentation/helpers/playback_controllers/playback_controller.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlaybackController implements PlaybackController {
  YoutubePlaybackController(this.controller);

  final YoutubePlayerController controller;

  Future<void> play() async {
    controller.play();
  }

  Future<void> pause() async {
    controller.pause();
  }

  Future<void> seek(double position) async {
    controller.seekTo(Duration(seconds: position.round()));
  }

  Future<double> getCurrentTime([String? _]) async {
    return controller.value.position.inSeconds.toDouble();
  }

  Future<bool> isPlaying() async {
    return controller.value.isPlaying;
  }

  @override
  Future<bool> hasVideoTag() async => true;

  @override
  Future<void> disableControls() async {
    //
  }
}
