import 'package:sync_together/core/utils/type_defs.dart';

/// **Base class for synchronous use cases with no parameters.**
///
/// - Returns `ResultFuture<T>`, ensuring a **failure or success** result.
/// - Used when a method does not require any input parameters.
abstract class UseCase<T> {
  /// Constructor for the [UseCase] class.
  const UseCase();

  /// Executes the use case logic.
  ///
  /// Returns **either**:
  /// - `T`: The successful result.
  /// - `Failure`: If an error occurs.
  ResultFuture<T> call();
}

/// **Base class for synchronous use cases that require parameters.**
///
/// - `Params`: Type of the input parameter.
/// - `T`: Type of the return value.
/// - Used when a method **needs additional data**
/// to execute (e.g., login credentials).
abstract class UseCaseWithParams<T, Params> {
  /// Constructor for the [UseCaseWithParams] class.
  const UseCaseWithParams();

  /// Executes the use case logic with the given [params].
  ///
  /// Returns **either**:
  /// - `T`: The successful result.
  /// - `Failure`: If an error occurs.
  ResultFuture<T> call(Params params);
}

/// **Base class for stream-based use cases with no parameters.**
///
/// - Returns `ResultFuture<T>`, ensuring a **failure or success** result.
/// - Used when a method does not require any input parameters.
abstract class StreamUseCase<T> {
  const StreamUseCase();
  ResultStream<T> call();
}

/// **Base class for stream-based use cases that require parameters.**
///
/// - `Params`: Type of the input parameter.
/// - `T`: Type of the emitted stream value.
/// - Used for **real-time updates** (e.g., listening to WebRTC signaling).
abstract class StreamUseCaseWithParams<T, Params> {
  const StreamUseCaseWithParams();
  ResultStream<T> call(Params params);
}
