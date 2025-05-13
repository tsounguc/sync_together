import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';

/// **PlatformsRepository Repository Interface**
///
/// Defines the contract for authentication-related operations.
/// This allows the app to remain **independent of Firebase**
/// or any other backend.
///
/// Each method **returns an Either type** (`ResultFuture<T>`),
/// ensuring that failures are handled explicitly instead of using exceptions.
abstract class PlatformsRepository {
  /// Loads the list of supported platforms
  ///
  /// - **Success:** Returns a list of [StreamingPlatform]
  /// - **Failure:** Returns a 'StreamingPlatformsFailure'
  ResultFuture<List<StreamingPlatform>> loadPlatforms();
}
