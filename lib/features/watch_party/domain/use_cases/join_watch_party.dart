import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

/// **Use Case: Join watch party**
///
/// Calls the [WatchPartyRepository] to join the watch party.

class JoinWatchParty extends UseCaseWithParams<void, JoinWatchPartyParams> {
  const JoinWatchParty(this.repository);

  final WatchPartyRepository repository;

  @override
  ResultFuture<WatchParty> call(
    JoinWatchPartyParams params,
  ) =>
      repository.joinWatchParty(
        partyId: params.partyId,
        userId: params.userId,
      );
}

/// **Parameters for Joining watch party**
///
/// Includes a partyId and a userId.
class JoinWatchPartyParams extends Equatable {
  const JoinWatchPartyParams({
    required this.partyId,
    required this.userId,
  });

  /// Empty constructor for testing purposes.
  const JoinWatchPartyParams.empty()
      : partyId = '',
        userId = '';

  /// The unique ID of the watch party session.
  final String partyId;

  /// ID of the user joining the session.
  final String userId;

  @override
  List<Object?> get props => [partyId, userId];
}
