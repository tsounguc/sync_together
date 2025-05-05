import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';
import 'package:sync_together/features/chat/domain/usecases/send_message.dart';

import 'chat_repository.mock.dart';

void main() {
  late ChatRepository repository;
  late SendMessage useCase;
  final testMessage = Message.empty();
  setUp(() {
    repository = MockChatRepository();
    useCase = SendMessage(repository);
    registerFallbackValue(testMessage);
  });

  final testFailure = SendMessageFailure(
    message: 'message',
    statusCode: 500,
  );
  final testParams = SendMessageParams.empty();

  test(
    'given SendMessage '
    'when instantiated '
    'then call [ChatRepository.sendMessage] successfully ',
    () async {
      // Arrange
      when(
        () => repository.sendMessage(
          roomId: any(named: 'roomId'),
          message: any(named: 'message'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, const Right<Failure, void>(null));
      verify(
        () => repository.sendMessage(
          roomId: testParams.roomId,
          message: testParams.message,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given SendMessage '
    'when instantiated '
    'and [ChatRepository.sendMessage] called unsuccessfully '
    'then return [SendMessageFailure] ',
    () async {
      // Arrange
      when(
        () => repository.sendMessage(
          roomId: any(named: 'roomId'),
          message: any(named: 'message'),
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
        () => repository.sendMessage(
          roomId: testParams.roomId,
          message: testParams.message,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
