import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sync_together/features/chat/domain/entities/message.dart';
import 'package:sync_together/features/chat/domain/repositories/chat_repository.dart';
import 'package:sync_together/features/chat/domain/usecases/listen_to_messages.dart';

import 'chat_repository.mock.dart';

void main() {
  late ChatRepository repository;
  late ListenToMessages useCase;

  setUp(() {
    repository = MockChatRepository();
    useCase = ListenToMessages(repository);
  });

  const testRoomId = '123';

  test(
    'given ListenToMessages '
    'when instantiated '
    'then call [ChatRepository.listenToMessages] '
    'and return a [Stream<List<Message>>] ',
    () async {
      // Arrange
      when(
        () => repository.listenToMessages(
          roomId: any(named: 'roomId'),
        ),
      ).thenAnswer((_) => Stream.value(const Right([])));

      // Act
      final result = useCase(testRoomId);

      // Assert
      expect(result, emits(const Right<dynamic, List<Message>>([])));
      verify(
        () => repository.listenToMessages(roomId: testRoomId),
      ).called(1);
    },
  );
}
