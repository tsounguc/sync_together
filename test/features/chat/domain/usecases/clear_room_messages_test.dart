import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';
import 'package:sync_together/features/chat/domain/usecases/clear_room_messages.dart';

import 'chat_repository.mock.dart';

void main() {
  late ChatRepository repository;
  late ClearRoomMessages useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = ClearRoomMessages(repository);
  });

  final testFailure = ClearRoomMessagesFailure(
    message: 'message',
    statusCode: 500,
  );

  const testRoomId = '123';

  test(
    'given ClearRoomMessages '
    'when instantiated '
    'then call [ChatRepository.clearRoomMessages] '
    'and return [void]',
    () async {
      // Arrange
      when(
        () => repository.clearRoomMessages(
          roomId: any(named: 'roomId'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testRoomId);

      // Assert
      expect(result, const Right<Failure, void>(null));
      verify(
        () => repository.clearRoomMessages(
          roomId: testRoomId,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given ClearRoomMessages '
    'when instantiated '
    'and [ChatRepository.clearRoomMessages] called unsuccessfully '
    'then return [ClearRoomMessagesFailure] ',
    () async {
      // Arrange
      when(
        () => repository.clearRoomMessages(
          roomId: any(named: 'roomId'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testRoomId);

      // Assert
      expect(result, Left<Failure, void>(testFailure));
      verify(
        () => repository.clearRoomMessages(
          roomId: testRoomId,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
