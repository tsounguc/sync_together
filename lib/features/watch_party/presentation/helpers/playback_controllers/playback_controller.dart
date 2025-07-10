abstract class PlaybackController {
  Future<void> play();

  Future<void> pause();

  Future<void> seek(double position);

  Future<double> getCurrentTime([String? currentTimeScript]);

  Future<bool> isPlaying();

  Future<bool> hasVideoTag(); // Optional for uniformity

  Future<void> disableControls();
}
