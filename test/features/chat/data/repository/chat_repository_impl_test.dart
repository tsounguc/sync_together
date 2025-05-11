import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:sync_together/features/chat/data/models/message_model.dart';
import 'package:sync_together/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';

class MockChatRemoteDataSource extends Mock implements ChatRemoteDataSource {}

void main() {
  late ChatRemoteDataSource remoteDataSource;
  late ChatRepositoryImpl repositoryImpl;

  setUp(() {
    remoteDataSource = MockChatRemoteDataSource();
    repositoryImpl = ChatRepositoryImpl(remoteDataSource);
    registerFallbackValue(MessageModel.empty());
  });

  const roomId = 'test id';
  final testMessage = MessageModel.empty();

  test(
    'given ChatRepositoryImpl '
    'when instantiated '
    'then instance is a subclass of [ChatRepository] ',
    () async {
      // Arrange
      // Act
      // Assert
      expect(repositoryImpl, isA<ChatRepository>());
    },
  );
  group('sendMessage - ', () {
    test(
      'given ChatRepositoryImpl, '
      'when [ChatRemoteDataSource.sendMessage] is called '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.sendMessage(
            roomId: any(named: 'roomId'),
            message: any(named: 'message'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repositoryImpl.sendMessage(roomId: roomId, message: testMessage);

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(
          () => remoteDataSource.sendMessage(
            roomId: roomId,
            message: testMessage,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );

    test(
      'given ChatRepositoryImpl, '
      'when call [ChatRemoteDataSource.sendMessage] is unsuccessful '
      'then return [SendMessageFailure]',
      () async {
        // Arrange
        const testException = SendMessageException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.sendMessage(
            roomId: any(named: 'roomId'),
            message: any(named: 'message'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.sendMessage(
          roomId: roomId,
          message: testMessage,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            SendMessageFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.sendMessage(
            roomId: roomId,
            message: testMessage,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('listenToMessages - ', () {
    test(
      'given ChatRepositoryImpl '
      'when [ChatRemoteDataSource.listenToMessages] is called '
      'then emit [List<Message>] ',
      () async {
        // Arrange
        final messages = [testMessage];
        when(
          () => remoteDataSource.listenToMessages(
            roomId: any(named: 'roomId'),
          ),
        ).thenAnswer((_) => Stream.value(messages));

        // Act
        final result = repositoryImpl.listenToMessages(roomId: roomId);

        // Assert
        expect(
          result,
          emits(Right<Failure, List<Message>>(messages)),
        );
        verify(
          () => remoteDataSource.listenToMessages(roomId: roomId),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
    test(
      'given ChatRepositoryImpl '
      'when call [ChatRemoteDataSource.listenToMessages] is unsuccessful '
      'then emit [ListenToMessagesFailure] ',
      () async {
        // Arrange
        const testException = ListenToMessagesException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.listenToMessages(
            roomId: any(named: 'roomId'),
          ),
        ).thenAnswer((_) => Stream.error(testException));

        // Act
        final result = repositoryImpl.listenToMessages(roomId: roomId);

        // Assert
        expect(
          result,
          emits(
            Left<Failure, List<Message>>(
              ListenToMessagesFailure.fromException(testException),
            ),
          ),
        );
        verify(
          () => remoteDataSource.listenToMessages(roomId: roomId),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('deleteMessage - ', () {
    test(
      'given ChatRepositoryImpl, '
      'when [ChatRemoteDataSource.deleteMessage] called successfully '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.deleteMessage(
            roomId: any(named: 'roomId'),
            messageId: any(named: 'messageId'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repositoryImpl.deleteMessage(
          roomId: roomId,
          messageId: testMessage.id,
        );

        // Assert
        expect(
          result,
          const Right<Failure, void>(null),
        );
        verify(
          () => remoteDataSource.deleteMessage(
            roomId: roomId,
            messageId: testMessage.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
    test(
      'given ChatRepositoryImpl, '
      'when call [ChatRemoteDataSource.deleteMessage] is unsuccessful '
      'then return [DeleteMessageFailure]',
      () async {
        // Arrange
        const testException = DeleteMessageException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.deleteMessage(
            roomId: any(named: 'roomId'),
            messageId: any(named: 'messageId'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.deleteMessage(
          roomId: roomId,
          messageId: testMessage.id,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            DeleteMessageFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.deleteMessage(
            roomId: roomId,
            messageId: testMessage.id,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('editMessage - ', () {
    test(
      'given ChatRepositoryImpl, '
      'when [ChatRemoteDataSource.editMessage] called successfully '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.editMessage(
            roomId: any(named: 'roomId'),
            messageId: any(named: 'messageId'),
            newText: any(named: 'newText'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repositoryImpl.editMessage(
          roomId: roomId,
          messageId: testMessage.id,
          newText: testMessage.text,
        );

        // Assert
        expect(
          result,
          const Right<Failure, void>(null),
        );
        verify(
          () => remoteDataSource.editMessage(
            roomId: roomId,
            messageId: testMessage.id,
            newText: testMessage.text,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
    test(
      'given ChatRepositoryImpl, '
      'when call [ChatRemoteDataSource.editMessage] is unsuccessful '
      'then return [EditMessageFailure]',
      () async {
        // Arrange
        const testException = EditMessageException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.editMessage(
            roomId: any(named: 'roomId'),
            messageId: any(named: 'messageId'),
            newText: any(named: 'newText'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.editMessage(
          roomId: roomId,
          messageId: testMessage.id,
          newText: testMessage.text,
        );

        // Assert
        expect(
          result,
          Left<Failure, void>(
            EditMessageFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.editMessage(
            roomId: roomId,
            messageId: testMessage.id,
            newText: testMessage.text,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('fetchMessages - ', () {
    test(
      'given ChatRepositoryImpl, '
      'when [ChatRemoteDataSource.fetchMessages] called successfully '
      'then return [List<Message>]',
      () async {
        // Arrange
        final messages = [MessageModel.empty()];
        when(
          () => remoteDataSource.fetchMessages(
            roomId: any(named: 'roomId'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => Future.value(messages));

        // Act
        final result = await repositoryImpl.fetchMessages(
          roomId: roomId,
          limit: 10,
        );

        // Assert
        expect(
          result,
          Right<Failure, List<Message>>(messages),
        );
        verify(
          () => remoteDataSource.fetchMessages(
            roomId: roomId,
            limit: 10,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
    test(
      'given ChatRepositoryImpl, '
      'when call [ChatRemoteDataSource.fetchMessages] is unsuccessful '
      'then return [FetchMessagesFailure]',
      () async {
        // Arrange
        const testException = FetchMessagesException(
          message: 'message',
          statusCode: '500',
        );
        when(
          () => remoteDataSource.fetchMessages(
            roomId: any(named: 'roomId'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.fetchMessages(
          roomId: roomId,
          limit: 10,
        );

        // Assert
        expect(
          result,
          Left<Failure, List<Message>>(
            FetchMessagesFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.fetchMessages(
            roomId: roomId,
            limit: 10,
          ),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });

  group('clearRoomMessages - ', () {
    test(
      'given ChatRepositoryImpl, '
      'when [ChatRemoteDataSource.clearRoomMessages] called successfully '
      'then return [void]',
      () async {
        // Arrange
        when(
          () => remoteDataSource.clearRoomMessages(
            roomId: any(named: 'roomId'),
          ),
        ).thenAnswer((_) async => Future.value());

        // Act
        final result = await repositoryImpl.clearRoomMessages(roomId: roomId);

        // Assert
        expect(result, const Right<Failure, void>(null));
        verify(
          () => remoteDataSource.clearRoomMessages(roomId: roomId),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
    test(
      'given ChatRepositoryImpl, '
      'when call [ChatRemoteDataSource.clearRoomMessages] is unsuccessful '
      'then return [ClearRoomMessagesFailure]',
      () async {
        // Arrange
        const testException = ClearRoomMessagesException(
          message: 'message',
          statusCode: 'statusCode',
        );
        when(
          () => remoteDataSource.clearRoomMessages(
            roomId: any(named: 'roomId'),
          ),
        ).thenThrow(testException);

        // Act
        final result = await repositoryImpl.clearRoomMessages(roomId: roomId);

        // Assert
        expect(
          result,
          Left<Failure, void>(
            ClearRoomMessagesFailure.fromException(testException),
          ),
        );
        verify(
          () => remoteDataSource.clearRoomMessages(roomId: roomId),
        ).called(1);
        verifyNoMoreInteractions(remoteDataSource);
      },
    );
  });
}
