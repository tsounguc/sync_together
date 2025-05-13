import 'package:flutter_test/flutter_test.dart';
import 'package:sync_together/features/platforms/data/models/streaming_platform_model.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const testModel = StreamingPlatformModel(
    name: 'YouTube',
    logoPath: 'assets/logos/yt_logo_dark.png',
    isDRMProtected: false,
    defaultUrl: 'https://www.youtube.com',
    packageName: 'com.google.android.youtube',
    deeplinkUrl: 'vnd.youtube://',
    appstoreUrl: 'https://apps.apple.com/app/youtube/id544007664',
    playStoreUrl: 'https://play.google.com/store/apps/details?id=com.google.android.youtube',
  );

  final testMap = {
    'name': 'YouTube',
    'logoPath': 'assets/logos/yt_logo_dark.png',
    'isDRMProtected': false,
    'defaultUrl': 'https://www.youtube.com',
    'packageName': 'com.google.android.youtube',
    'deeplinkUrl': 'vnd.youtube://',
    'appstoreUrl': 'https://apps.apple.com/app/youtube/id544007664',
    'playStoreUrl': 'https://play.google.com/store/apps/details?id=com.google.android.youtube',
  };

  test(
    'given [StreamingPlatformModel], '
    'when instantiated '
    'then instance should be a subclass of [StreamingPlatform] entity',
    () {
      // Arrange
      // Act
      final result = StreamingPlatformModel.fromMap(testMap);
      // Assert
      expect(result, equals(testModel));
    },
  );

  group('fromJson/toJson', () {
    test(
      'given [StreamingPlatformModel], '
      'when toJson and fromJson are called '
      'then it should return identical model',
      () {
        final json = testModel.toJson();
        final parsed = StreamingPlatformModel.fromJson(json);
        expect(parsed, equals(testModel));
      },
    );
  });

  group('fromMap - ', () {
    test(
      'given [StreamingPlatformModel], '
      'when fromMap is called, '
      'then return [StreamingPlatformModel] with correct data ',
      () {
        // Arrange
        // Act
        final result = StreamingPlatformModel.fromMap(testMap);
        // Assert
        expect(result, isA<StreamingPlatformModel>());
        expect(result, equals(testModel));
      },
    );
  });

  group('toMap - ', () {
    test(
      'given [StreamingPlatformModel], '
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
    const testNewName = 'Netflix';
    test(
      'given [StreamingPlatformModel], '
      'when copyWith is called, '
      'then return [StreamingPlatformModel] with updated data ',
      () {
        // Arrange
        // Act
        final result = testModel.copyWith(name: testNewName);
        // Assert
        expect(result.name, equals(testNewName));
      },
    );
  });
}
