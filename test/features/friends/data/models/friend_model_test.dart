import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/friends/data/models/friend_model.dart';
import 'package:sync_together/features/friends/domain/entities/friend.dart';

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

  final testFriendModel = FriendModel.empty().copyWith(createdAt: date);

  final testMap = jsonDecode(fixture('friend.json')) as DataMap;

  testMap['createdAt'] = timestamp;

  test(
    'given [FriendModel], '
    'when instantiated '
    'then instance should be subclass of [Friend]',
    () {
      // Arrange
      // Act

      // Assert
      expect(testFriendModel, isA<Friend>());
    },
  );
  group('fromMap - ', () {
    test(
      'given [FriendModel], '
      'when fromMap is called, '
      'then return [FriendModel] with correct data ',
      () {
        // Arrange
        // Act
        final result = FriendModel.fromMap(testMap);
        // Assert
        expect(result, isA<FriendModel>());
        expect(result, equals(testFriendModel));
      },
    );
  });

  group('toMap - ', () {
    test(
      'given [FriendModel], '
      'when toMap is called, '
      'then return [Map] with correct data ',
      () {
        // Arrange
        // Act
        final result = testFriendModel.toMap();
        // Assert
        expect(result, equals(testMap));
      },
    );
  });

  group('copyWith - ', () {
    const testName = 'Jane Doe';
    test(
      'given [FriendModel], '
      'when copyWith is called, '
      'then return [FriendModel] with updated data ',
      () {
        // Arrange
        // Act
        final result = testFriendModel.copyWith(user1Name: testName);
        // Assert
        expect(result.user1Name, equals(testName));
      },
    );
  });
}
