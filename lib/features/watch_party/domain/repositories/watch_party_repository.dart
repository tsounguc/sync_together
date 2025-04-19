import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';

/// **Repository contract for handling Watch Party operations**.
abstract class WatchPartyRepository {
  /// Creates a new watch party session.
  ///
  /// - **Success:** Returns `WatchParty`.
  /// - **Failure:** Returns a `WatchPartyFailure`.
  ResultFuture<WatchParty> createWatchParty({
    required WatchPartyModel party,
  });

  /// Joins an existing watch party.
  ///
  /// - **Success:** Returns `WatchParty`.
  /// - **Failure:** Returns a `WatchPartyFailure`.
  ResultFuture<WatchParty> joinWatchParty({
    required String partyId,
    required String userId,
  });

  /// Returns a list of public watch party sessions.
  ///
  /// - **Success:** Returns a list of `WatchParty` entities.
  /// - **Failure:** Returns a `WatchPartyFailure`.
  ResultFuture<List<WatchParty>> getPublicWatchParties();

  /// Retrieves an active watch party by its ID.
  ///
  /// - **Success:** Returns a `WatchParty` entity.
  /// - **Failure:** Returns a `WatchPartyFailure`.
  ResultFuture<WatchParty> getWatchParty(String partyId);

  /// Starts watch party.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns a `WatchPartyFailure`.
  ResultVoid startParty({required String partyId});

  /// Gets watch party start status
  ///
  /// - **Success:** Returns bool.
  /// - **Failure:** Returns a `WatchPartyFailure`.
  ResultStream<bool> watchStartStatus({required String partyId});
}
