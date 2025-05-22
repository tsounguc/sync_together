import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/data/data_sources/watch_party_remote_data_source.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
import 'package:sync_together/features/watch_party/data/repositories/watch_party_repository_impl.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';
import 'package:sync_together/features/watch_party/domain/repositories/watch_party_repository.dart';

class MockWatchPartyRemoteDataSource extends Mock implements WatchPartyRemoteDataSource {}

void main() {
  late WatchPartyRemoteDataSource remoteDataSource;
  late WatchPartyRepositoryImpl repositoryImpl;
  final testModel = WatchPartyModel.empty();

  setUp(() {
    remoteDataSource = MockWatchPartyRemoteDataSource();
    repositoryImpl = WatchPartyRepositoryImpl(remoteDataSource);
    registerFallbackValue(testModel);
  });

  test('given WatchPartyRepositoryImpl ', () async {
    // Arrange
    // Act
    // Assert
    expect(repositoryImpl, isA<WatchPartyRepository>());
  });

  group('createWatchParty - ', () {
    test(
      'given WatchPartyRepositoryImpl, '
      'when [WatchPartyRemoteDataSource.createWatchParty] is called '
      'then return [WatchParty]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.createWatchParty(
            party: any(named: 'party'),
          ),
        ).thenAnswer((_) async => Future.value(testModel));

        // Act
        final result = await repositoryImpl.createWatchParty(party: testModel);

        // Assert
        expect(result, Right<Failure, WatchParty>(testModel));
        verify(
          () => remoteDataSource.createWatchParty(
            party: testModel,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given WatchPartyRepositoryImpl, '
      'when call [WatchPartyRemoteDataSource.createWatchParty] is unsuccessful '
      'then return [CreateWatchPartyFailure]',
      () async {
        // Arrange
        const testException = CreateWatchPartyException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.createWatchParty(
            party: any(named: 'party'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.createWatchParty(party: testModel);

        // Assert
        expect(
          result,
          Left<Failure, WatchParty>(
            CreateWatchPartyFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.createWatchParty(
            party: testModel,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('joinWatchParty - ', () {
    test(
      'given WatchPartyRepositoryImpl, '
      'when [WatchPartyRemoteDataSource.joinWatchParty] is called '
      'then return [WatchParty]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.joinWatchParty(
            partyId: any(named: 'partyId'),
            userId: any(named: 'userId'),
          ),
        ).thenAnswer((_) async => Future.value(testModel));

        // Act
        final result = await repositoryImpl.joinWatchParty(
          partyId: testModel.id,
          userId: testModel.hostId,
        );

        // Assert
        expect(result, Right<Failure, WatchParty>(testModel));
        verify(
          () => remoteDataSource.joinWatchParty(
            partyId: testModel.id,
            userId: testModel.hostId,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given WatchPartyRepositoryImpl, '
      'when call [WatchPartyRemoteDataSource.joinWatchParty] is unsuccessful '
      'then return [CreateWatchPartyFailure]',
      () async {
        // Arrange
        const testException = JoinWatchPartyException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.joinWatchParty(
            partyId: any(named: 'partyId'),
            userId: any(named: 'userId'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.joinWatchParty(
          partyId: testModel.id,
          userId: testModel.hostId,
        );

        // Assert
        expect(
          result,
          Left<Failure, WatchParty>(
            JoinWatchPartyFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.joinWatchParty(
            partyId: testModel.id,
            userId: testModel.hostId,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('getPublicWatchParties - ', () {
    test(
      'given WatchPartyRepositoryImpl, '
      'when [WatchPartyRemoteDataSource.getPublicWatchParties] is called '
      'then return [List<WatchParty>]',
      () async {
        // Arrange
        final publicParties = <WatchPartyModel>[];
        when(
          () => remoteDataSource.getPublicWatchParties(),
        ).thenAnswer((_) async => Future.value(publicParties));

        // Act
        final result = await repositoryImpl.getPublicWatchParties();

        // Assert
        expect(result, Right<Failure, List<WatchParty>>(publicParties));
        verify(
          () => remoteDataSource.getPublicWatchParties(),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given WatchPartyRepositoryImpl, '
      'when call [WatchPartyRemoteDataSource.getPublicWatchParties] is unsuccessful '
      'then return [GetPublicWatchPartiesFailure]',
      () async {
        // Arrange
        const testException = GetPublicWatchPartiesException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.getPublicWatchParties(),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.getPublicWatchParties();

        // Assert
        expect(
          result,
          Left<Failure, List<WatchParty>>(
            GetPublicWatchPartiesFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.getPublicWatchParties(),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('getWatchParty - ', () {
    test(
      'given WatchPartyRepositoryImpl, '
      'when [WatchPartyRemoteDataSource.getWatchParty] is called '
      'then return [WatchParty]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.getWatchParty(
            any(),
          ),
        ).thenAnswer((_) async => Future.value(testModel));

        // Act
        final result = await repositoryImpl.getWatchParty(
          testModel.id,
        );

        // Assert
        expect(result, Right<Failure, WatchParty>(testModel));
        verify(
          () => remoteDataSource.getWatchParty(
            testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given WatchPartyRepositoryImpl, '
      'when call [WatchPartyRemoteDataSource.getWatchParty] is unsuccessful '
      'then return [GetWatchPartyFailure]',
      () async {
        // Arrange
        const testException = GetWatchPartyException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.getWatchParty(
            any(),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.getWatchParty(
          testModel.id,
        );

        // Assert
        expect(
          result,
          Left<Failure, WatchParty>(
            GetWatchPartyFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.getWatchParty(
            testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('leaveWatchParty - ', () {
    test(
      'given WatchPartyRepositoryImpl, '
      'when [WatchPartyRemoteDataSource.leaveWatchParty] is called '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.leaveWatchParty(
            userId: any(named: 'userId'),
            partyId: any(named: 'partyId'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repositoryImpl.leaveWatchParty(
          userId: testModel.hostId,
          partyId: testModel.id,
        );

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(
          () => remoteDataSource.leaveWatchParty(
            userId: testModel.hostId,
            partyId: testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given WatchPartyRepositoryImpl, '
      'when call [WatchPartyRemoteDataSource.leaveWatchParty] is unsuccessful '
      'then return [LeaveWatchPartyFailure]',
      () async {
        // Arrange
        const testException = LeaveWatchPartyException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.leaveWatchParty(
            userId: any(named: 'userId'),
            partyId: any(named: 'partyId'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.leaveWatchParty(
          userId: testModel.hostId,
          partyId: testModel.id,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            LeaveWatchPartyFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.leaveWatchParty(
            userId: testModel.hostId,
            partyId: testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('endWatchParty - ', () {
    test(
      'given WatchPartyRepositoryImpl, '
      'when [WatchPartyRemoteDataSource.endWatchParty] is called '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.endWatchParty(
            partyId: any(named: 'partyId'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repositoryImpl.endWatchParty(
          partyId: testModel.id,
        );

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(
          () => remoteDataSource.endWatchParty(
            partyId: testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given WatchPartyRepositoryImpl, '
      'when call [WatchPartyRemoteDataSource.endWatchParty] is unsuccessful '
      'then return [EndWatchPartyFailure]',
      () async {
        // Arrange
        const testException = EndWatchPartyException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.endWatchParty(
            partyId: any(named: 'partyId'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.endWatchParty(
          partyId: testModel.id,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            EndWatchPartyFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.endWatchParty(
            partyId: testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('listenToParticipants - ', () {
    test(
      'given WatchPartyRepositoryImpl, '
      'when [WatchPartyRemoteDataSource.listenToParticipants] is called '
      'then return [List<String>]',
      () async {
        // Arrange
        final testParticipants = [testModel.hostId];
        when(
          () => remoteDataSource.listenToParticipants(
            partyId: any(named: 'partyId'),
          ),
        ).thenAnswer((_) => Stream.value(testParticipants));

        // Act
        final result = repositoryImpl.listenToParticipants(
          partyId: testModel.id,
        );

        // Assert
        expect(result, emits(Right<Failure, List<String>>(testParticipants)));
        verify(
          () => remoteDataSource.listenToParticipants(
            partyId: testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given WatchPartyRepositoryImpl, '
      'when call [WatchPartyRemoteDataSource.listenToParticipants] is unsuccessful '
      'then return [ListenToParticipantsFailure]',
      () async {
        // Arrange
        const testException = ListenToParticipantsException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.listenToParticipants(
            partyId: any(named: 'partyId'),
          ),
        ).thenAnswer((_) => Stream.error(testException));

        // Act
        final result = repositoryImpl.listenToParticipants(
          partyId: testModel.id,
        );

        // Assert
        expect(
          result,
          emits(
            Left<Failure, List<String>>(
              ListenToParticipantsFailure.fromException(testException),
            ),
          ),
        );
        verify(
          () => remoteDataSource.listenToParticipants(
            partyId: testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('startParty - ', () {
    test(
      'given WatchPartyRepositoryImpl, '
      'when [WatchPartyRemoteDataSource.startParty] is called '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.startParty(
            partyId: any(named: 'partyId'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repositoryImpl.startParty(
          partyId: testModel.id,
        );

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(
          () => remoteDataSource.startParty(
            partyId: testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given WatchPartyRepositoryImpl, '
      'when call [WatchPartyRemoteDataSource.startParty] is unsuccessful '
      'then return [StartWatchPartyFailure]',
      () async {
        // Arrange
        const testException = StartWatchPartyException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.startParty(
            partyId: any(named: 'partyId'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.startParty(
          partyId: testModel.id,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            StartWatchPartyFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.startParty(
            partyId: testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('listenToPartyStart - ', () {
    test(
      'given WatchPartyRepositoryImpl, '
      'when [WatchPartyRemoteDataSource.listenToPartyStart] is called '
      'then return [bool]',
      () async {
        // Arrange

        when(
          () => remoteDataSource.listenToPartyStart(
            partyId: any(named: 'partyId'),
          ),
        ).thenAnswer((_) => Stream.value(testModel.hasStarted));

        // Act
        final result = repositoryImpl.listenToPartyStart(
          partyId: testModel.id,
        );

        // Assert
        expect(result, emits(Right<Failure, bool>(testModel.hasStarted)));
        verify(
          () => remoteDataSource.listenToPartyStart(
            partyId: testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given WatchPartyRepositoryImpl, '
      'when call [WatchPartyRemoteDataSource.listenToPartyStart] is unsuccessful '
      'then return [ListenToPartyStartFailure]',
      () async {
        // Arrange
        const testException = ListenToPartyStartException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.listenToPartyStart(
            partyId: any(named: 'partyId'),
          ),
        ).thenAnswer((_) => Stream.error(testException));

        // Act
        final result = repositoryImpl.listenToPartyStart(
          partyId: testModel.id,
        );

        // Assert
        expect(
          result,
          emits(
            Left<Failure, bool>(
              ListenToPartyStartFailure.fromException(testException),
            ),
          ),
        );
        verify(
          () => remoteDataSource.listenToPartyStart(
            partyId: testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('updateVideoUrl - ', () {
    const testNewUrl = 'testNewUrl';
    test(
      'given WatchPartyRepositoryImpl, '
      'when [WatchPartyRemoteDataSource.updateVideoUrl] is called '
      'then return [void]',
      () async {
        // Arrange

        when(
          () => remoteDataSource.updateVideoUrl(
            partyId: any(named: 'partyId'),
            newUrl: any(named: 'newUrl'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repositoryImpl.updateVideoUrl(
          partyId: testModel.id,
          newUrl: testNewUrl,
        );

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(
          () => remoteDataSource.updateVideoUrl(
            partyId: testModel.id,
            newUrl: testNewUrl,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given WatchPartyRepositoryImpl, '
      'when call [WatchPartyRemoteDataSource.updateVideoUrl] is unsuccessful '
      'then return [SyncWatchPartyFailure]',
      () async {
        // Arrange
        const testException = SyncWatchPartyException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.updateVideoUrl(
            partyId: any(named: 'partyId'),
            newUrl: testNewUrl,
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.updateVideoUrl(
          partyId: testModel.id,
          newUrl: testNewUrl,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            SyncWatchPartyFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.updateVideoUrl(
            partyId: testModel.id,
            newUrl: testNewUrl,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('sendSyncData - ', () {
    test(
      'given WatchPartyRepositoryImpl, '
      'when [WatchPartyRemoteDataSource.sendSyncData] is called '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.sendSyncData(
            partyId: any(named: 'partyId'),
            playbackPosition: any(named: 'playbackPosition'),
            isPlaying: any(named: 'isPlaying'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repositoryImpl.sendSyncData(
          partyId: testModel.id,
          playbackPosition: 5,
          isPlaying: true,
        );

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(
          () => remoteDataSource.sendSyncData(
            partyId: testModel.id,
            playbackPosition: 5,
            isPlaying: true,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given WatchPartyRepositoryImpl, '
      'when call [WatchPartyRemoteDataSource.startParty] is unsuccessful '
      'then return [SendSyncDataFailure]',
      () async {
        // Arrange
        const testException = SendSyncDataException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.sendSyncData(
            partyId: any(named: 'partyId'),
            playbackPosition: any(named: 'playbackPosition'),
            isPlaying: any(named: 'isPlaying'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.sendSyncData(
          partyId: testModel.id,
          playbackPosition: 5,
          isPlaying: true,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            SendSyncDataFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.sendSyncData(
            partyId: testModel.id,
            playbackPosition: 5,
            isPlaying: true,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('getSyncedData - ', () {
    test(
      'given WatchPartyRepositoryImpl, '
      'when [WatchPartyRemoteDataSource.getSyncedData] is called '
      'then return [Map<String,dynamic>]',
      () async {
        // Arrange
        final syncedData = {'playbackPosition': 7};
        when(
          () => remoteDataSource.getSyncedData(
            partyId: any(named: 'partyId'),
          ),
        ).thenAnswer((_) => Stream.value(syncedData));

        // Act
        final result = repositoryImpl.getSyncedData(
          partyId: testModel.id,
        );

        // Assert
        expect(result, emits(Right<Failure, DataMap>(syncedData)));
        verify(
          () => remoteDataSource.getSyncedData(
            partyId: testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given WatchPartyRepositoryImpl, '
      'when call [WatchPartyRemoteDataSource.getSyncedData] is unsuccessful '
      'then return [GetSyncedDataFailure]',
      () async {
        // Arrange
        const testException = GetSyncedDataException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.getSyncedData(
            partyId: any(named: 'partyId'),
          ),
        ).thenAnswer((_) => Stream.error(testException));

        // Act
        final result = repositoryImpl.getSyncedData(
          partyId: testModel.id,
        );

        // Assert
        expect(
          result,
          emits(
            Left<Failure, bool>(
              GetSyncedDataFailure.fromException(testException),
            ),
          ),
        );
        verify(
          () => remoteDataSource.getSyncedData(
            partyId: testModel.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });
}
