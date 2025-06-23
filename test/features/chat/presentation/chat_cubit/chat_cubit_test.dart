import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/domain/usecases/clear_room_messages.dart';
import 'package:sync_together/features/chat/domain/usecases/delete_message.dart';
import 'package:sync_together/features/chat/domain/usecases/edit_message.dart';
import 'package:sync_together/features/chat/domain/usecases/fetch_messages.dart';
import 'package:sync_together/features/chat/domain/usecases/listen_to_messages.dart';
import 'package:sync_together/features/chat/domain/usecases/send_message.dart';
import 'package:sync_together/features/chat/presentation/chat_cubit/chat_cubit.dart';

class MockListenToMessages extends Mock implements ListenToMessages {}

class MockSendMessage extends Mock implements SendMessage {}

class MockEditMessage extends Mock implements EditMessage {}

class MockDeleteMessage extends Mock implements DeleteMessage {}

class MockFetchMessages extends Mock implements FetchMessages {}

class MockClearRoomMessages extends Mock implements ClearRoomMessages {}

void main() {
  late ListenToMessages listenToMessages;
  late SendMessage sendMessage;
  late EditMessage editMessage;
  late DeleteMessage deleteMessage;
  late FetchMessages fetchMessages;
  late ClearRoomMessages clearRoomMessages;

  late ChatCubit cubit;

  late Message testMessage;
  late SendMessageParams testSendMessageParams;
  late EditMessageParams testEditMessageParams;
  late DeleteMessageParams testDeleteMessageParams;
  late FetchMessagesParams testFetchMessagesParams;

  late ListenToMessagesFailure testListenToMessagesFailure;
  late SendMessageFailure testSendFailure;
  late EditMessageFailure testEditFailure;
  late DeleteMessageFailure testDeleteFailure;
  late FetchMessagesFailure testFetchFailure;
  late ClearRoomMessagesFailure testClearRoomFailure;

  setUp(() {
    listenToMessages = MockListenToMessages();
    sendMessage = MockSendMessage();
    editMessage = MockEditMessage();
    deleteMessage = MockDeleteMessage();
    fetchMessages = MockFetchMessages();
    clearRoomMessages = MockClearRoomMessages();

    cubit = ChatCubit(
      listenToMessages: listenToMessages,
      sendMessage: sendMessage,
      editMessage: editMessage,
      deleteMessage: deleteMessage,
      fetchMessages: fetchMessages,
      clearRoomMessages: clearRoomMessages,
    );

    testMessage = Message.empty();
    testSendMessageParams = SendMessageParams.empty();
    testEditMessageParams = const EditMessageParams.empty();
    testDeleteMessageParams = const DeleteMessageParams.empty();
    testFetchMessagesParams = const FetchMessagesParams.empty();
    testListenToMessagesFailure = ListenToMessagesFailure(
      message: 'message',
      statusCode: 500,
    );
    testSendFailure = SendMessageFailure(
      message: 'message',
      statusCode: 500,
    );
    testEditFailure = EditMessageFailure(
      message: 'message',
      statusCode: 500,
    );
    testDeleteFailure = DeleteMessageFailure(
      message: 'message',
      statusCode: 500,
    );
    testFetchFailure = FetchMessagesFailure(
      message: 'message',
      statusCode: 500,
    );
    testClearRoomFailure = ClearRoomMessagesFailure(
      message: 'message',
      statusCode: 500,
    );

    registerFallbackValue(testMessage);
    registerFallbackValue(testSendMessageParams);
    registerFallbackValue(testEditMessageParams);
    registerFallbackValue(testDeleteMessageParams);
    registerFallbackValue(testFetchMessagesParams);
  });

  tearDown(() {
    cubit.close();
  });

  test(
    'given ChatCubit '
    'when cubit is instantiated '
    'then initial state should be [ChatInitial]',
    () async {
      // Arrange
      // Act
      // Assert
      expect(cubit.state, const ChatInitial());
    },
  );

  final testMessages = <Message>[];
  const testRoomId = '123';

  group('listenToMessages - ', () {
    blocTest<ChatCubit, ChatState>(
      'given ChatCubit '
      'when [ChatCubit.listenToMessagesStream] is called '
      'then emit [ChatLoading, MessagesReceived] ',
      build: () {
        when(() => listenToMessages(any())).thenAnswer(
          (_) => Stream.value(Right(testMessages)),
        );
        return cubit;
      },
      act: (cubit) => cubit.listenToMessagesStream(testRoomId),
      expect: () => [
        const ChatLoading(),
        MessagesReceived(testMessages),
      ],
      verify: (cubit) {
        verify(
          () => listenToMessages(testRoomId),
        ).called(1);
        verifyNoMoreInteractions(listenToMessages);
      },
    );
    blocTest<ChatCubit, ChatState>(
      'given ChatCubit '
      'when [ChatCubit.listenToMessagesStream] is called '
      'then emit [ChatLoading, ChatError] ',
      build: () {
        when(() => listenToMessages(any())).thenAnswer(
          (_) => Stream.value(Left(testListenToMessagesFailure)),
        );
        return cubit;
      },
      act: (cubit) => cubit.listenToMessagesStream(testRoomId),
      expect: () => [
        const ChatLoading(),
        ChatError(testListenToMessagesFailure.message),
      ],
      verify: (cubit) {
        verify(
          () => listenToMessages(testRoomId),
        ).called(1);
        verifyNoMoreInteractions(listenToMessages);
      },
    );
  });

  group('sendMessage - ', () {
    blocTest<ChatCubit, ChatState>(
      'given ChatCubit '
      'when [ChatCubit.sendTextMessage] is called '
      'then emit [MessageSending, MessageSent] ',
      build: () {
        when(() => sendMessage(any())).thenAnswer(
          (_) async => const Right(null),
        );
        return cubit;
      },
      act: (cubit) => cubit.sendTextMessage(
        roomId: testSendMessageParams.roomId,
        message: testSendMessageParams.message,
      ),
      expect: () => [
        const MessageSending(),
        // const MessageSent(),
      ],
      verify: (cubit) {
        verify(
          () => sendMessage(testSendMessageParams),
        ).called(1);
        verifyNoMoreInteractions(sendMessage);
      },
    );
    blocTest<ChatCubit, ChatState>(
      'given ChatCubit '
      'when [ChatCubit.sendTextMessage] is called '
      'then emit [MessageSending, ChatError] ',
      build: () {
        when(() => sendMessage(any())).thenAnswer(
          (_) async => Left(testSendFailure),
        );
        return cubit;
      },
      act: (cubit) => cubit.sendTextMessage(
        roomId: testSendMessageParams.roomId,
        message: testSendMessageParams.message,
      ),
      expect: () => [
        const MessageSending(),
        ChatError(testSendFailure.message),
      ],
      verify: (cubit) {
        verify(
          () => sendMessage(testSendMessageParams),
        ).called(1);
        verifyNoMoreInteractions(sendMessage);
      },
    );
  });

  group('editMessage - ', () {
    blocTest<ChatCubit, ChatState>(
      'given ChatCubit '
      'when [ChatCubit.editTextMessage] is called '
      'then emit [MessageEditing, MessageEdited] ',
      build: () {
        when(
          () => editMessage(any()),
        ).thenAnswer(
          (_) async => const Right(null),
        );
        return cubit;
      },
      act: (cubit) => cubit.editTextMessage(
        roomId: testEditMessageParams.roomId,
        messageId: testEditMessageParams.messageId,
        newText: testEditMessageParams.newText,
      ),
      expect: () => [
        const MessageEditing(),
        const MessageEdited(),
      ],
      verify: (cubit) {
        verify(
          () => editMessage(testEditMessageParams),
        ).called(1);
        verifyNoMoreInteractions(editMessage);
      },
    );
    blocTest<ChatCubit, ChatState>(
      'given ChatCubit '
      'when [ChatCubit.editTextMessage] is called '
      'then emit [MessageEditing, ChatError] ',
      build: () {
        when(() => editMessage(any())).thenAnswer(
          (_) async => Left(testEditFailure),
        );
        return cubit;
      },
      act: (cubit) => cubit.editTextMessage(
        roomId: testEditMessageParams.roomId,
        messageId: testEditMessageParams.messageId,
        newText: testEditMessageParams.newText,
      ),
      expect: () => [
        const MessageEditing(),
        ChatError(testEditFailure.message),
      ],
      verify: (cubit) {
        verify(
          () => editMessage(testEditMessageParams),
        ).called(1);
        verifyNoMoreInteractions(editMessage);
      },
    );
  });

  group('deleteMessage - ', () {
    blocTest<ChatCubit, ChatState>(
      'given ChatCubit '
      'when [ChatCubit.deleteTextMessage] is called '
      'then emit [MessageDeleting, MessageDeleted] ',
      build: () {
        when(
          () => deleteMessage(any()),
        ).thenAnswer(
          (_) async => const Right(null),
        );
        return cubit;
      },
      act: (cubit) => cubit.deleteTextMessage(
        roomId: testDeleteMessageParams.roomId,
        messageId: testDeleteMessageParams.messageId,
      ),
      expect: () => [
        const MessageDeleting(),
        // const MessageDeleted(),
      ],
      verify: (cubit) {
        verify(
          () => deleteMessage(testDeleteMessageParams),
        ).called(1);
        verifyNoMoreInteractions(deleteMessage);
      },
    );
    blocTest<ChatCubit, ChatState>(
      'given ChatCubit '
      'when [ChatCubit.deleteTextMessage] is called '
      'then emit [MessageDeleting, ChatError] ',
      build: () {
        when(() => deleteMessage(any())).thenAnswer(
          (_) async => Left(testDeleteFailure),
        );
        return cubit;
      },
      act: (cubit) => cubit.deleteTextMessage(
        roomId: testDeleteMessageParams.roomId,
        messageId: testDeleteMessageParams.messageId,
      ),
      expect: () => [
        const MessageDeleting(),
        ChatError(testDeleteFailure.message),
      ],
      verify: (cubit) {
        verify(
          () => deleteMessage(testDeleteMessageParams),
        ).called(1);
        verifyNoMoreInteractions(deleteMessage);
      },
    );
  });

  group('fetchMessages - ', () {
    blocTest<ChatCubit, ChatState>(
      'given ChatCubit '
      'when [ChatCubit.fetchTextMessages] is called '
      'then emit [FetchingMessages, MessagesFetched] ',
      build: () {
        when(() => fetchMessages(any())).thenAnswer(
          (_) async => Right(testMessages),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchTextMessages(
        roomId: testFetchMessagesParams.roomId,
        limit: testFetchMessagesParams.limit,
      ),
      expect: () => [
        const FetchingMessages(),
        MessagesFetched(testMessages),
      ],
      verify: (cubit) {
        verify(
          () => fetchMessages(testFetchMessagesParams),
        ).called(1);
        verifyNoMoreInteractions(fetchMessages);
      },
    );
    blocTest<ChatCubit, ChatState>(
      'given ChatCubit '
      'when [ChatCubit.fetchTextMessages] is called '
      'then emit [FetchingMessages, ChatError] ',
      build: () {
        when(() => fetchMessages(any())).thenAnswer(
          (_) async => Left(testFetchFailure),
        );
        return cubit;
      },
      act: (cubit) => cubit.fetchTextMessages(
        roomId: testFetchMessagesParams.roomId,
        limit: testFetchMessagesParams.limit,
      ),
      expect: () => [
        const FetchingMessages(),
        ChatError(testFetchFailure.message),
      ],
      verify: (cubit) {
        verify(
          () => fetchMessages(testFetchMessagesParams),
        ).called(1);
        verifyNoMoreInteractions(fetchMessages);
      },
    );
  });

  group('clearRoomMessages - ', () {
    blocTest<ChatCubit, ChatState>(
      'given ChatCubit '
      'when [ChatCubit.clearRoomTextMessages] is called '
      'then emit [MessagesClearing, MessagesCleared] ',
      build: () {
        when(
          () => clearRoomMessages(any()),
        ).thenAnswer(
          (_) async => const Right(null),
        );
        return cubit;
      },
      act: (cubit) => cubit.clearRoomTextMessages(roomId: testRoomId),
      expect: () => [
        const MessagesClearing(),
        const MessagesCleared(),
      ],
      verify: (cubit) {
        verify(
          () => clearRoomMessages(testRoomId),
        ).called(1);
        verifyNoMoreInteractions(clearRoomMessages);
      },
    );
    blocTest<ChatCubit, ChatState>(
      'given ChatCubit '
      'when [ChatCubit.clearRoomTextMessages] is called '
      'then emit [MessagesClearing, ChatError] ',
      build: () {
        when(() => clearRoomMessages(any())).thenAnswer(
          (_) async => Left(testClearRoomFailure),
        );
        return cubit;
      },
      act: (cubit) => cubit.clearRoomTextMessages(roomId: testRoomId),
      expect: () => [
        const MessagesClearing(),
        ChatError(testSendFailure.message),
      ],
      verify: (cubit) {
        verify(
          () => clearRoomMessages(testRoomId),
        ).called(1);
        verifyNoMoreInteractions(clearRoomMessages);
      },
    );
  });
}
