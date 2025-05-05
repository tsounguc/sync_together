import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';
import 'package:sync_together/features/chat/domain/usecases/delete_message.dart';

import 'chat_repository.mock.dart';

void main() {
  late ChatRepository repository;
  late DeleteMessage useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = DeleteMessage(repository);
  });

  final testFailure = DeleteMessageFailure(
    message: 'message',
    statusCode: 500,
  );
  const testParams = DeleteMessageParams.empty();

  test(
    'given DeleteMessage '
    'when instantiated '
    'then call [ChatRepository.deleteMessage] successfully ',
    () async {
      // Arrange
      when(
        () => repository.deleteMessage(
          roomId: any(named: 'roomId'),
          messageId: any(
            named: 'messageId',
          ),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, const Right<Failure, void>(null));
      verify(
        () => repository.deleteMessage(
          roomId: testParams.roomId,
          messageId: testParams.messageId,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given DeleteMessage '
    'when instantiated '
    'and [ChatRepository.deleteMessage] called unsuccessfully '
    'then return [DeleteMessageFailure] ',
    () async {
      // Arrange
      when(
        () => repository.deleteMessage(
          roomId: any(named: 'roomId'),
          messageId: any(
            named: 'messageId',
          ),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(
        result,
        Left<Failure, void>(testFailure),
      );
      verify(
        () => repository.deleteMessage(
          roomId: testParams.roomId,
          messageId: testParams.messageId,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
