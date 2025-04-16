import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';

/// **Repository contract for handling Watch Party operations**.
abstract class WatchPartyRepository {
  /// Creates a new watch party session.
  ///
  /// - **Success:** Returns the `WatchParty` entity.
  /// - **Failure:** Returns a `WatchPartyFailure`.
  ResultFuture<WatchParty> createWatchParty({
    required WatchPartyModel party,
  });

  /// Joins an existing watch party.
  ///
  /// - **Success:** Returns `void`.
  /// - **Failure:** Returns a `WatchPartyFailure`.
  ResultVoid joinWatchParty({
    required String partyId,
    required String userId,
  });

  /// Retrieves an active watch party by its ID.
  ///
  /// - **Success:** Returns a `WatchParty` entity.
  /// - **Failure:** Returns a `WatchPartyFailure`.
  ResultFuture<WatchParty> getWatchParty(String partyId);
}
