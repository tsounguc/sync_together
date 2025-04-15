import 'dart:convert';

import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/platforms/domain/entities/streaming_platform.dart';

class StreamingPlatformModel extends StreamingPlatform {
  const StreamingPlatformModel({
    required super.name,
    required super.logoPath,
    required super.isDRMProtected,
    required super.defaultUrl,
    super.packageName,
    super.deeplinkUrl,
    super.appstoreUrl,
    super.playStoreUrl,
  });

  const StreamingPlatformModel.empty()
      : this(
          name: '',
          logoPath: '',
          isDRMProtected: false,
          defaultUrl: '',
        );

  factory StreamingPlatformModel.fromJson(String source) =>
      StreamingPlatformModel.fromMap(jsonDecode(source) as DataMap);

  StreamingPlatformModel.fromMap(DataMap dataMap)
      : this(
          name: dataMap['name'] as String,
          logoPath: dataMap['logoPath'] as String,
          isDRMProtected: dataMap['isDRMProtected'] as bool,
          defaultUrl: dataMap['defaultUrl'] as String,
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
        'isDRMProtected': isDRMProtected,
        'defaultUrl': defaultUrl,
        'packageName': packageName,
        'deeplinkUrl': deeplinkUrl,
        'appstoreUrl': appstoreUrl,
        'playStoreUrl': playStoreUrl,
      };

  StreamingPlatformModel copyWith({
    String? name,
    String? logoPath,
    bool? isDRMProtected,
    String? defaultUrl,
    String? packageName,
    String? deeplinkUrl,
    String? appstoreUrl,
    String? playStoreUrl,
  }) {
    return StreamingPlatformModel(
      name: name ?? this.name,
      logoPath: logoPath ?? this.logoPath,
      isDRMProtected: isDRMProtected ?? this.isDRMProtected,
      defaultUrl: defaultUrl ?? this.defaultUrl,
      packageName: packageName ?? this.packageName,
      deeplinkUrl: deeplinkUrl ?? this.deeplinkUrl,
      appstoreUrl: appstoreUrl ?? this.appstoreUrl,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
    );
  }
}
