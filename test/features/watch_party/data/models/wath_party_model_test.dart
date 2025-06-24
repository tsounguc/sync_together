import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final timestampData = {
    '_seconds': 1741020300,
    '_nanoseconds': 0,
  };

  final date = DateTime.fromMillisecondsSinceEpoch(
    timestampData['_seconds']!,
  ).add(
    Duration(microseconds: timestampData['_nanoseconds']!),
  );

  final timestamp = Timestamp.fromDate(date);

  final testModel = WatchPartyModel.empty().copyWith(
    createdAt: date,
    lastSyncedTime: date,
  );

  final testMap = jsonDecode(fixture('watch_party.json')) as DataMap;

  testMap['createdAt'] = timestamp;

  testMap['lastSyncedTime'] = timestamp;

  test(
    'given [WatchPartyModel], '
    'when instantiated '
    'then instance should be a subclass of [WatchParty]',
    () async {
      // Arrange
      // Act
      final result = WatchPartyModel.fromMap(testMap);
      // Assert
      expect(result, equals(testModel));
    },
  );

  group('fromMap - ', () {
    test(
      'given [WatchPartyModel], ',
      () {
        // Arrange
        // Act
        final result = WatchPartyModel.fromMap(testMap);

        // Assert
        expect(result, isA<WatchPartyModel>());
        expect(result, equals(testModel));
      },
    );
  });

  group('toMap - ', () {
    test('given [WatchPartyModel], ', () {
      // Arrange
      // Act
      final result = testModel.toMap();
      // Assert
      expect(result, equals(testMap));
    });
  });

  group('copyWith - ', () {
    const isPlaying = true;
    test(
      'given [MessageModel], '
      'when copyWith is called, '
      'then return [UserModel] with updated data ',
      () {
        // Arrange
        // Act
        final result = testModel.copyWith(isPlaying: isPlaying);
        // Assert
        expect(result.isPlaying, equals(isPlaying));
      },
    );
  });
}
