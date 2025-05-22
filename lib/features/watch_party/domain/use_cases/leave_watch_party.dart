import 'package:equatable/equatable.dart';
import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

/// **Use Case: Leave watch party**
///
/// Calls the [WatchPartyRepository] to leave the watch party.
class LeaveWatchParty extends UseCaseWithParams<void, LeaveWatchPartyParams> {
  const LeaveWatchParty(this.repository);

  final WatchPartyRepository repository;

  @override
  ResultVoid call(LeaveWatchPartyParams params) => repository.leaveWatchParty(
        userId: params.userId,
        partyId: params.partyId,
      );
}

/// **Parameters for leaving a watch party**
///
/// Includes an email and password.
class LeaveWatchPartyParams extends Equatable {
  const LeaveWatchPartyParams({
    required this.partyId,
    required this.userId,
  });

  /// Empty constructor for testing purposes.
  const LeaveWatchPartyParams.empty()
      : partyId = '',
        userId = '';

  /// The unique ID of the watch party session.
  final String partyId;

  /// ID of the user joining the session.
  final String userId;

  @override
  List<Object?> get props => [partyId, userId];
}
