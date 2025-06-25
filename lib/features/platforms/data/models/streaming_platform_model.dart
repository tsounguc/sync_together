import 'dart:convert';

import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';

/// **StreamingPlatformModel** represents the Json file user data model.
///
/// This extends [StreamingPlatform] and includes JSON serialization methods.
class StreamingPlatformModel extends StreamingPlatform {
  const StreamingPlatformModel({
    required super.name,
    required super.logoPath,
    required super.logoDarkPath,
    required super.isDRMProtected,
    required super.defaultUrl,
    required super.playScript,
    required super.pauseScript,
    required super.currentTimeScript,
    super.packageName,
    super.deeplinkUrl,
    super.appstoreUrl,
    super.playStoreUrl,
  });

  /// Represents an empty [StreamingPlatformModel] instance.
  ///
  /// Used for default values or initializing empty states.
  const StreamingPlatformModel.empty()
      : this(
          name: '_empty.name',
          logoPath: '_empty.logoPath',
          logoDarkPath: '_emptylogoDarkPath',
          isDRMProtected: false,
          defaultUrl: '_empty.defaultUrl',
          playScript: '_empty.playScript',
          pauseScript: '_empty.pauseScript',
          currentTimeScript: '_empty.currentTimeScript',
          packageName: null,
          deeplinkUrl: null,
          appstoreUrl: null,
          playStoreUrl: null,
        );

  /// Creates a [StreamingPlatformModel] from a JSON string.
  factory StreamingPlatformModel.fromJson(String source) =>
      StreamingPlatformModel.fromMap(jsonDecode(source) as DataMap);

  /// Creates a [StreamingPlatformModel] from a key-value map.
  StreamingPlatformModel.fromMap(DataMap dataMap)
      : this(
          name: dataMap['name'] as String,
          logoPath: dataMap['logoPath'] as String,
          logoDarkPath: dataMap['logoDarkPath'] as String,
          isDRMProtected: dataMap['isDRMProtected'] as bool,
          defaultUrl: dataMap['defaultUrl'] as String,
          playScript: dataMap['playScript'] as String,
          pauseScript: dataMap['pauseScript'] as String,
          currentTimeScript: dataMap['currentTimeScript'] as String,
          packageName: dataMap['packageName'] as String?,
          deeplinkUrl: dataMap['deeplinkUrl'] as String?,
          appstoreUrl: dataMap['appstoreUrl'] as String?,
          playStoreUrl: dataMap['playStoreUrl'] as String?,
        );

  /// Converts a [StreamingPlatformModel] instance to a JSON string.
  String toJson() => jsonEncode(toMap());

  /// Converts a [StreamingPlatformModel] instance to a key-value map.
  DataMap toMap() => {
        'name': name,
        'logoPath': logoPath,
        'logoDarkPath': logoDarkPath,
        'isDRMProtected': isDRMProtected,
        'defaultUrl': defaultUrl,
        'playScript': playScript,
        'pauseScript': pauseScript,
        'currentTimeScript': currentTimeScript,
        'packageName': packageName,
        'deeplinkUrl': deeplinkUrl,
        'appstoreUrl': appstoreUrl,
        'playStoreUrl': playStoreUrl,
      };

  /// Creates a copy of the current [StreamingPlatformModel]
  /// with optional updates.
  StreamingPlatformModel copyWith({
    String? name,
    String? logoPath,
    String? logoDarkPath,
    bool? isDRMProtected,
    String? defaultUrl,
    String? playScript,
    String? pauseScript,
    String? currentTimeScript,
    String? packageName,
    String? deeplinkUrl,
    String? appstoreUrl,
    String? playStoreUrl,
  }) {
    return StreamingPlatformModel(
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
      logoDarkPath: logoDarkPath ?? this.logoDarkPath,
      isDRMProtected: isDRMProtected ?? this.isDRMProtected,
      playScript: playScript ?? this.playScript,
      pauseScript: pauseScript ?? this.pauseScript,
      currentTimeScript: currentTimeScript ?? this.currentTimeScript,
      defaultUrl: defaultUrl ?? this.defaultUrl,
      packageName: packageName ?? this.packageName,
      deeplinkUrl: deeplinkUrl ?? this.deeplinkUrl,
      appstoreUrl: appstoreUrl ?? this.appstoreUrl,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
    );
  }
}
