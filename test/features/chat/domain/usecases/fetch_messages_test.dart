import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/core/errors/failures.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';
import 'package:sync_together/features/chat/domain/usecases/fetch_messages.dart';

import 'chat_repository.mock.dart';

void main() {
  late ChatRepository repository;
  late FetchMessages useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = FetchMessages(repository);
  });

  final testFailure = FetchMessagesFailure(
    message: 'message',
    statusCode: 500,
  );

  const testParams = FetchMessagesParams.empty();

  test(
    'given FetchMessages '
    'when instantiated '
    'then call [ChatRepository.fetchMessages] '
    'and return [List<Message>] ',
    () async {
      // Arrange
      when(
        () => repository.fetchMessages(
          roomId: any(named: 'roomId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, const Right<Failure, List<Message>>([]));
      verify(
        () => repository.fetchMessages(
          roomId: testParams.roomId,
          limit: testParams.limit,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );

  test(
    'given FetchMessages '
    'when instantiated '
    'and [ChatRepository.fetchMessages] called unsuccessfully '
    'then return [FetchMessagesFailure] ',
    () async {
      // Arrange
      when(
        () => repository.fetchMessages(
          roomId: any(named: 'roomId'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Left(testFailure));

      // Act
      final result = await useCase(testParams);

      // Assert
      expect(result, Left<Failure, List<Message>>(testFailure));
      verify(
        () => repository.fetchMessages(
          roomId: testParams.roomId,
          limit: testParams.limit,
        ),
      ).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
