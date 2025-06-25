import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sync_together/core/resources/media_resources.dart';
import 'package:sync_together/features/platforms/data/data_sources/platforms_data_source.dart';
import 'package:sync_together/features/platforms/data/models/streaming_platform_model.dart';

void main() {
  late PlatformsDataSourceImpl dataSourceImpl;

  const platformsJson = '''
    [
      {
        "name": "YouTube",
        "logoPath": "assets/logos/yt_logo_light.png",
        "logoDarkPath": "assets/logos/yt_logo_dark.png",
        "isDRMProtected": false,
        "defaultUrl": "https://www.youtube.com",
        "playScript": "document.querySelector('video')?.play()",
        "pauseScript": "document.querySelector('video')?.pause()",
        "currentTimeScript": "document.querySelector('video')?.currentTime",
        "packageName": "com.google.android.youtube",
        "deepLinkUrl": "vnd.youtube://",
        "appstoreUrl": "",
        "playStoreUrl": ""
      }
    ]
  ''';

  const testPlatform = StreamingPlatformModel(
    name: 'YouTube',
    logoPath: 'assets/logos/yt_logo_dark.png',
    logoDarkPath: 'assets/logos/yt_logo_light.png',
    isDRMProtected: false,
    defaultUrl: 'https://www.youtube.com',
    playScript: "document.querySelector('video')?.play()",
    pauseScript: "document.querySelector('video')?.pause()",
    currentTimeScript: "document.querySelector('video')?.currentTime",
    packageName: 'com.google.android.youtube',
    deeplinkUrl: 'vnd.youtube://',
    appstoreUrl: 'https://apps.apple.com/app/youtube/id544007664',
    playStoreUrl:
        'https://play.google.com/store/apps/details?id=com.google.android.youtube',
  );

  setUp(() {
    dataSourceImpl = PlatformsDataSourceImpl();
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'given valid json file '
    'when [AssetBundle.loadString] is called '
    'then return list of StreamingPlatformModel ',
    () async {
      // Arrange
      const assetPath = MediaResources.platFormsData;
      final assetBundle = rootBundle;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(
        'flutter/assets',
        (message) async {
          final key = utf8.decoder.convert(message!.buffer.asUint8List());
          if (key == assetPath) {
            return ByteData.view(utf8.encoder.convert(platformsJson).buffer);
          }
          return null;
        },
      );

      // Act
      final result = await dataSourceImpl.loadPlatforms();

      // Assert
      expect(result, isA<List<StreamingPlatformModel>>());
      expect(result.length, 1);
      expect(result.first, equals(testPlatform));
    },
  );

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });
}
