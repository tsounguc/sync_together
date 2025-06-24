import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/create_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/end_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_synced_data.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_user_by_id.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/get_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/join_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/leave_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/listen_to_participants.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/listen_to_party_existence.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/listen_to_party_start.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/send_sync_data.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/start_watch_party.dart';
import 'package:sync_together/features/watch_party/domain/use_cases/update_video_url.dart';
import 'package:sync_together/features/watch_party/presentation/watch_party_session_bloc/watch_party_session_bloc.dart';

class MockCreateWatchParty extends Mock implements CreateWatchParty {}

class MockJoinWatchParty extends Mock implements JoinWatchParty {}

class MockGetWatchParty extends Mock implements GetWatchParty {}

class MockLeaveWatchParty extends Mock implements LeaveWatchParty {}

class MockEndWatchParty extends Mock implements EndWatchParty {}

class MockListenToParticipants extends Mock implements ListenToParticipants {}

class MockStartParty extends Mock implements StartWatchParty {}

class MockListenToPartyStart extends Mock implements ListenToPartyStart {}

class MockUpdateVideoUrl extends Mock implements UpdateVideoUrl {}

class MockSendSyncData extends Mock implements SendSyncData {}

class MockGetSyncedData extends Mock implements GetSyncedData {}

class MockGetUserById extends Mock implements GetUserById {}

class MockListenToPartyExistence extends Mock implements ListenToPartyExistence {}

void main() {
  late CreateWatchParty createWatchParty;
  late JoinWatchParty joinWatchParty;
  late GetWatchParty getWatchParty;
  late LeaveWatchParty leaveWatchParty;
  late EndWatchParty endWatchParty;
  late ListenToParticipants listenToParticipants;
  late StartWatchParty startParty;
  late ListenToPartyStart listenToPartyStart;
  late UpdateVideoUrl updateVideoUrl;
  late SendSyncData sendSyncData;
  late GetSyncedData getSyncedData;
  late GetUserById getUserById;
  late ListenToPartyExistence listenToPartyExistence;

  late WatchPartySessionBloc bloc;

  const joinPartyParams = JoinWatchPartyParams.empty();

  const leavePartyParams = LeaveWatchPartyParams.empty();

  const updateVideoUrlParams = UpdateVideoUrlParams.empty();

  const sendSyncDataParams = SendSyncDataParams.empty();

  final testCreatePartyFailure = CreateWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  final testJoinPartyFailure = JoinWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  final testGetWatchPartyFailure = GetWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  final testLeaveWatchPartyFailure = LeaveWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  final testEndWatchPartyFailure = EndWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  final testListenToParticipantsFailure = ListenToParticipantsFailure(
    message: 'message',
    statusCode: 500,
  );

  final testStartPartyFailure = StartWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  final testListenToPartyStartFailure = ListenToPartyStartFailure(
    message: 'message',
    statusCode: 500,
  );

  final testSyncPartyFailure = SyncWatchPartyFailure(
    message: 'message',
    statusCode: 500,
  );

  final testParty = WatchParty.empty();

  setUp(() {
    createWatchParty = MockCreateWatchParty();
    joinWatchParty = MockJoinWatchParty();
    getWatchParty = MockGetWatchParty();
    leaveWatchParty = MockLeaveWatchParty();
    endWatchParty = MockEndWatchParty();
    listenToParticipants = MockListenToParticipants();
    startParty = MockStartParty();
    listenToPartyStart = MockListenToPartyStart();
    updateVideoUrl = MockUpdateVideoUrl();
    sendSyncData = MockSendSyncData();
    getSyncedData = MockGetSyncedData();
    getUserById = MockGetUserById();
    listenToPartyExistence = MockListenToPartyExistence();

    bloc = WatchPartySessionBloc(
      createWatchParty: createWatchParty,
      joinWatchParty: joinWatchParty,
      getWatchParty: getWatchParty,
      leaveWatchParty: leaveWatchParty,
      endWatchParty: endWatchParty,
      listenToParticipants: listenToParticipants,
      startParty: startParty,
      listenToPartyStart: listenToPartyStart,
      updateVideoUrl: updateVideoUrl,
      sendSyncData: sendSyncData,
      getSyncedData: getSyncedData,
      getUserById: getUserById,
      listenToPartyExistence: listenToPartyExistence,
    );

    registerFallbackValue(testParty);
    registerFallbackValue(joinPartyParams);
    registerFallbackValue(leavePartyParams);
    registerFallbackValue(updateVideoUrlParams);
    registerFallbackValue(sendSyncDataParams);

    when(() => getUserById(any())).thenAnswer(
      (_) async => const Right(UserEntity.empty()),
    );
  });

  test(
    'given WatchPartySessionBloc '
    'when bloc is instantiated '
    'then initial state should [WatchPartySessionInitial]',
    () async {
      // Arrange
      // Act
      // Assert
      expect(bloc.state, const WatchPartySessionInitial());
    },
  );

  group('createWatchParty - ', () {
    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.createWatchParty] is called '
      'and completed successfully '
      'then emit [WatchPartyLoading, WatchPartyCreated]',
      build: () {
        when(
          () => createWatchParty(
            any(),
          ),
        ).thenAnswer((_) async => Right(testParty));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateWatchPartyEvent(party: testParty)),
      expect: () => [
        WatchPartyLoading(),
        WatchPartyCreated(testParty),
      ],
      verify: (_) {
        verify(() => createWatchParty(testParty)).called(1);
      },
    );

    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.createWatchParty] is called unsuccessfully '
      'then emit [WatchPartyLoading, WatchPartyError]',
      build: () {
        when(
          () => createWatchParty(
            any(),
          ),
        ).thenAnswer((_) async => Left(testCreatePartyFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateWatchPartyEvent(party: testParty)),
      expect: () => [
        WatchPartyLoading(),
        WatchPartyError(testCreatePartyFailure.message),
      ],
      verify: (_) {
        verify(
          () => createWatchParty(testParty),
        ).called(1);
      },
    );
  });

  group('joinWatchParty - ', () {
    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.joinWatchParty] is called '
      'and completed successfully '
      'then emit [WatchPartyLoading, WatchPartyJoined]',
      build: () {
        when(
          () => joinWatchParty(
            any(),
          ),
        ).thenAnswer((_) async => Right(testParty));
        return bloc;
      },
      act: (bloc) => bloc.add(
        JoinWatchPartyEvent(
          partyId: joinPartyParams.partyId,
          userId: joinPartyParams.userId,
        ),
      ),
      expect: () => [
        WatchPartyLoading(),
        WatchPartyJoined(testParty),
      ],
      verify: (_) {
        verify(
          () => joinWatchParty(joinPartyParams),
        ).called(1);
      },
    );

    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.joinWatchParty] is called unsuccessfully '
      'then emit [WatchPartyLoading, WatchPartyError]',
      build: () {
        when(
          () => joinWatchParty(
            any(),
          ),
        ).thenAnswer((_) async => Left(testJoinPartyFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        JoinWatchPartyEvent(
          partyId: joinPartyParams.partyId,
          userId: joinPartyParams.userId,
        ),
      ),
      expect: () => [
        WatchPartyLoading(),
        WatchPartyError(testJoinPartyFailure.message),
      ],
      verify: (_) {
        verify(
          () => joinWatchParty(joinPartyParams),
        ).called(1);
      },
    );
  });

  group('getWatchParty - ', () {
    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.getWatchParty] is called '
      'and completed successfully '
      'then emit [WatchPartyLoading, WatchPartyFetched]',
      build: () {
        when(
          () => getWatchParty(
            any(),
          ),
        ).thenAnswer((_) async => Right(testParty));
        return bloc;
      },
      act: (bloc) => bloc.add(
        GetWatchPartyEvent(testParty.id),
      ),
      expect: () => [
        WatchPartyLoading(),
        WatchPartyFetched(testParty),
      ],
      verify: (_) {
        verify(
          () => getWatchParty(testParty.id),
        ).called(1);
      },
    );

    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.getWatchParty] is called unsuccessfully '
      'then emit [WatchPartyLoading, WatchPartyError]',
      build: () {
        when(
          () => getWatchParty(any()),
        ).thenAnswer((_) async => Left(testGetWatchPartyFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        GetWatchPartyEvent(testParty.id),
      ),
      expect: () => [
        WatchPartyLoading(),
        WatchPartyError(testGetWatchPartyFailure.message),
      ],
      verify: (_) {
        verify(
          () => getWatchParty(testParty.id),
        ).called(1);
      },
    );
  });

  group('leaveWatchParty - ', () {
    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.leaveWatchParty] is called '
      'and completed successfully '
      'then emit [WatchPartyLoading, WatchPartyFetched]',
      build: () {
        when(
          () => leaveWatchParty(
            any(),
          ),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        LeaveWatchPartyEvent(
          partyId: leavePartyParams.partyId,
          userId: leavePartyParams.userId,
        ),
      ),
      expect: () => [
        WatchPartyLoading(),
        const WatchPartyLeft(),
      ],
      verify: (_) {
        verify(
          () => leaveWatchParty(leavePartyParams),
        ).called(1);
      },
    );

    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.leaveWatchParty] is called unsuccessfully '
      'then emit [WatchPartyLoading, WatchPartyError]',
      build: () {
        when(
          () => leaveWatchParty(any()),
        ).thenAnswer((_) async => Left(testLeaveWatchPartyFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        LeaveWatchPartyEvent(
          partyId: leavePartyParams.partyId,
          userId: leavePartyParams.userId,
        ),
      ),
      expect: () => [
        WatchPartyLoading(),
        WatchPartyError(testLeaveWatchPartyFailure.message),
      ],
      verify: (_) {
        verify(
          () => leaveWatchParty(leavePartyParams),
        ).called(1);
      },
    );
  });

  group('endWatchParty - ', () {
    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.getWatchParty] is called '
      'and completed successfully '
      'then emit [WatchPartyLoading, WatchPartyFetched]',
      build: () {
        when(
          () => endWatchParty(
            any(),
          ),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        EndWatchPartyEvent(testParty.id),
      ),
      expect: () => [
        WatchPartyLoading(),
        const WatchPartyEnded(),
      ],
      verify: (_) {
        verify(
          () => endWatchParty(testParty.id),
        ).called(1);
      },
    );

    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.endWatchParty] is called unsuccessfully '
      'then emit [WatchPartyLoading, WatchPartyError]',
      build: () {
        when(
          () => endWatchParty(any()),
        ).thenAnswer((_) async => Left(testEndWatchPartyFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        EndWatchPartyEvent(testParty.id),
      ),
      expect: () => [
        WatchPartyLoading(),
        WatchPartyError(testEndWatchPartyFailure.message),
      ],
      verify: (_) {
        verify(
          () => endWatchParty(testParty.id),
        ).called(1);
      },
    );
  });

  group('listenToParticipants - ', () {
    final testParticipantIds = [
      const UserEntity.empty(),
      const UserEntity.empty(),
    ];
    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.listenToParticipants] is called '
      'and completed successfully '
      'then emit [WatchPartyLoading, WatchPartyFetched]',
      build: () {
        when(
          () => listenToParticipants(
            any(),
          ),
        ).thenAnswer(
          (_) => Stream.value(
            Right(
              [testParticipantIds[0].uid, testParticipantIds[1].uid],
            ),
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        ListenToParticipantsEvent(testParty.id),
      ),
      expect: () => [
        WatchPartyLoading(),
        ParticipantsProfilesUpdated(testParticipantIds),
      ],
      verify: (_) {
        verify(
          () => listenToParticipants(testParty.id),
        ).called(1);
      },
    );

    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.listenToParticipants] is called unsuccessfully '
      'then emit [WatchPartyLoading, WatchPartyError]',
      build: () {
        when(
          () => listenToParticipants(any()),
        ).thenAnswer(
          (_) => Stream.value(Left(testListenToParticipantsFailure)),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        ListenToParticipantsEvent(testParty.id),
      ),
      expect: () => [
        WatchPartyLoading(),
        WatchPartyError(testListenToParticipantsFailure.message),
      ],
      verify: (_) {
        verify(
          () => listenToParticipants(testParty.id),
        ).called(1);
      },
    );
  });

  group('startParty - ', () {
    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.startParty] is called '
      'and completed successfully '
      'then emit [WatchPartyLoading, WatchPartyStarted]',
      build: () {
        when(
          () => startParty(
            any(),
          ),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        StartPartyEvent(testParty.id),
      ),
      expect: () => [
        WatchPartyLoading(),
        WatchPartyStarted(),
      ],
      verify: (_) {
        verify(
          () => startParty(testParty.id),
        ).called(1);
      },
    );

    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.startParty] is called unsuccessfully '
      'then emit [WatchPartyLoading, WatchPartyError]',
      build: () {
        when(
          () => startParty(any()),
        ).thenAnswer((_) async => Left(testStartPartyFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        StartPartyEvent(testParty.id),
      ),
      expect: () => [
        WatchPartyLoading(),
        WatchPartyError(testStartPartyFailure.message),
      ],
      verify: (_) {
        verify(
          () => startParty(testParty.id),
        ).called(1);
      },
    );
  });

  group('listenToPartyStart - ', () {
    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.listenToPartyStart] is called '
      'and completed successfully '
      'then emit [WatchPartyLoading, PartyStartedRealtime]',
      build: () {
        when(
          () => listenToPartyStart(
            any(),
          ),
        ).thenAnswer((_) => Stream.value(const Right(true)));
        return bloc;
      },
      act: (bloc) => bloc.add(
        ListenToPartyStartEvent(testParty.id),
      ),
      expect: () => [
        WatchPartyLoading(),
        const PartyStartedRealtime(),
      ],
      verify: (_) {
        verify(
          () => listenToPartyStart(testParty.id),
        ).called(1);
      },
    );

    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.listenToPartyStart] is called unsuccessfully '
      'then emit [WatchPartyLoading, WatchPartyError]',
      build: () {
        when(
          () => listenToPartyStart(any()),
        ).thenAnswer((_) => Stream.value(Left(testListenToPartyStartFailure)));
        return bloc;
      },
      act: (bloc) => bloc.add(
        ListenToPartyStartEvent(testParty.id),
      ),
      expect: () => [
        WatchPartyLoading(),
        WatchPartyError(testListenToPartyStartFailure.message),
      ],
      verify: (_) {
        verify(
          () => listenToPartyStart(testParty.id),
        ).called(1);
      },
    );
  });

  group('updateVideoUrl - ', () {
    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.updateVideoUrl] is called '
      'and completed successfully '
      'then emit []',
      build: () {
        when(
          () => updateVideoUrl(
            any(),
          ),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        UpdateVideoUrlEvent(
          partyId: updateVideoUrlParams.partyId,
          newUrl: updateVideoUrlParams.newUrl,
        ),
      ),
      expect: () => <WatchPartySessionState>[VideoUrlUpdated()],
      verify: (_) {
        verify(
          () => updateVideoUrl(updateVideoUrlParams),
        ).called(1);
      },
    );

    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.updateVideoUrl] is called unsuccessfully '
      'then emit [WatchPartyLoading, WatchPartyError]',
      build: () {
        when(
          () => updateVideoUrl(any()),
        ).thenAnswer((_) async => Left(testSyncPartyFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        UpdateVideoUrlEvent(
          partyId: updateVideoUrlParams.partyId,
          newUrl: updateVideoUrlParams.newUrl,
        ),
      ),
      expect: () => [
        WatchPartyError(testSyncPartyFailure.message),
      ],
      verify: (_) {
        verify(
          () => updateVideoUrl(updateVideoUrlParams),
        ).called(1);
      },
    );
  });

  group('sendSyncData - ', () {
    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.sendSyncData] is called '
      'and completed successfully '
      'then emit [ SyncDataSent]',
      build: () {
        when(
          () => sendSyncData(
            any(),
          ),
        ).thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SendSyncDataEvent(
          partyId: sendSyncDataParams.partyId,
          playbackPosition: sendSyncDataParams.playbackPosition,
          isPlaying: sendSyncDataParams.isPlaying,
        ),
      ),
      expect: () => <WatchPartySessionState>[],
      verify: (_) {
        verify(
          () => sendSyncData(sendSyncDataParams),
        ).called(1);
      },
    );

    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.sendSyncData] is called unsuccessfully '
      'then emit [ WatchPartyError]',
      build: () {
        when(
          () => sendSyncData(any()),
        ).thenAnswer((_) async => Left(testSyncPartyFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SendSyncDataEvent(
          partyId: sendSyncDataParams.partyId,
          playbackPosition: sendSyncDataParams.playbackPosition,
          isPlaying: sendSyncDataParams.isPlaying,
        ),
      ),
      expect: () => [
        WatchPartyError(testSyncPartyFailure.message),
      ],
      verify: (_) {
        verify(
          () => sendSyncData(sendSyncDataParams),
        ).called(1);
      },
    );
  });

  group('getSyncedData - ', () {
    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.getSyncedData] is called '
      'and completed successfully '
      'then emit [ SyncDataSent]',
      build: () {
        when(() => getSyncedData(any())).thenAnswer(
          (_) => Stream.value(const Right({})),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        GetSyncedDataEvent(
          partyId: testParty.id,
        ),
      ),
      expect: () => [
        const SyncUpdated(
          playbackPosition: 0,
          isPlaying: false,
        ),
      ],
      verify: (_) {
        verify(
          () => getSyncedData(testParty.id),
        ).called(1);
      },
    );

    blocTest<WatchPartySessionBloc, WatchPartySessionState>(
      'given WatchPartySessionBloc '
      'when [WatchPartySessionBloc.getSyncedData] is called unsuccessfully '
      'then emit [ WatchPartyError]',
      build: () {
        when(() => getSyncedData(any())).thenAnswer(
          (_) => Stream.value(Left(testSyncPartyFailure)),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(
        GetSyncedDataEvent(
          partyId: testParty.id,
        ),
      ),
      expect: () => [
        WatchPartyError(testSyncPartyFailure.message),
      ],
      verify: (_) {
        verify(
          () => getSyncedData(testParty.id),
        ).called(1);
      },
    );
  });
}
