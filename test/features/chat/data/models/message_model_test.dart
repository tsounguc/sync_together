import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/chat/data/models/message_model.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final timestampData = {
    '_seconds': 1677483548,
    '_nanoseconds': 123456000,
  };

  final date = DateTime.fromMillisecondsSinceEpoch(timestampData['_seconds']!).add(
    Duration(microseconds: timestampData['_nanoseconds']!),
  );

  final timestamp = Timestamp.fromDate(date);

  final testModel = MessageModel.empty().copyWith(timestamp: date);

  final testMap = jsonDecode(fixture('message.json')) as DataMap;

  testMap['timestamp'] = timestamp;

  test(
    'given [MessageModel], '
    'when instantiated '
    'then instance should be a subclass of [Message] entity',
    () {
      // Arrange
      // Act
      final result = MessageModel.fromMap(testMap);
      // Assert
      expect(result, equals(testModel));
    },
  );

  group('fromMap - ', () {
    test(
      'given [MessageModel], '
      'when fromMap is called, '
      'then return [MessageModel] with correct data ',
      () {
        // Arrange
        // Act
        final result = MessageModel.fromMap(testMap);
        // Assert
        expect(result, isA<MessageModel>());
        expect(result, equals(testModel));
      },
    );
  });

  group('toMap - ', () {
    test(
      'given [MessageModel], '
      'when toMap is called, '
      'then return [Map] with correct data ',
      () {
        // Arrange
        // Act
        final result = testModel.toMap();
        // Assert
        expect(result, equals(testMap));
      },
    );
  });

  group('copyWith - ', () {
    const testText = 'hello world';
    test(
      'given [MessageModel], '
      'when copyWith is called, '
      'then return [UserModel] with updated data ',
      () {
        // Arrange
        // Act
        final result = testModel.copyWith(text: testText);
        // Assert
        expect(result.text, equals(testText));
      },
    );
  });
}
