import 'package:sync_together/core/usecases/usecase.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

class ListenToParticipants extends StreamUseCaseWithParams<List<String>, String> {
  const ListenToParticipants(this.repository);
  final WatchPartyRepository repository;
  @override
  ResultStream<List<String>> call(
    String params,
  ) =>
      repository.listenToParticipants(partyId: params);
}
