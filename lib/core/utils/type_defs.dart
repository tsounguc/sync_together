import 'package:dartz/dartz.dart';
import 'package:sync_together/core/errors/failures.dart';

/// A shorthand type definition for functions
/// returning a [Future] containing either:
/// - A **successful result** of type `T`
/// - A **failure** ([Failure]).
///
/// This improves readability and
/// enforces proper error handling using the `Either` type from Dartz.
typedef ResultFuture<T> = Future<Either<Failure, T>>;

/// A shorthand type definition for **stream-based results**, where:
/// - A **successful event** emits a value of type `T`
/// - A **failure** ([Failure]) can also be emitted.
///
/// This is useful for **real-time updates** (e.g., WebRTC signaling).
typedef ResultStream<T> = Stream<Either<Failure, T>>;

/// A shorthand for `Future<void>` responses that return
/// a **success or failure**.
///
/// Example: Signing out a user does not return data but **can fail**.
typedef ResultVoid = ResultFuture<void>;

/// A shorthand for JSON-style maps (`Map<String, dynamic>`).
///
/// Useful for working with **Firestore, APIs,
/// or local storage** where data is stored as key-value pairs.
typedef DataMap = Map<String, dynamic>;
