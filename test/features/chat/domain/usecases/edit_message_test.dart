import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';
import 'package:sync_together/features/chat/domain/usecases/edit_message.dart';

import 'chat_repository.mock.dart';

void main() {
  late ChatRepository repository;
  late EditMessage useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = EditMessage(repository);
  });

  final testFailure = EditMessageFailure(
    message: 'message',
    statusCode: 500,
  );

  const testParams = EditMessageParams.empty();
  test(
    'given EditMessage '
    'when instantiated '
    'then call [ChatRepository.editMessage] '
    'and return [void] ',
    () async {
      // Arrange
      when(
        () => repository.editMessage(
          roomId: any(named: 'roomId'),
          messageId: any(named: 'messageId'),
          newText: any(named: 'newText'),
        ),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, const Right<Failure, void>(null));
      verify(
        () => repository.editMessage(
          roomId: testParams.roomId,
          messageId: testParams.messageId,
          newText: testParams.newText,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given EditMessage '
    'when instantiated '
    'and [ChatRepository.editMessage] called unsuccessfully '
    'then return [EditMessageFailure] ',
    () async {
      // Arrange
      when(
        () => repository.editMessage(
          roomId: any(named: 'roomId'),
          messageId: any(named: 'messageId'),
          newText: any(named: 'newText'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, Left<Failure, void>(testFailure));
      verify(
        () => repository.editMessage(
          roomId: testParams.roomId,
          messageId: testParams.messageId,
          newText: testParams.newText,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
