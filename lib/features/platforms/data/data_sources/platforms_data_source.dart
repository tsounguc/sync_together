import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sync_together/core/resources/media_resources.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/platforms/data/models/streaming_platform_model.dart';

abstract class PlatformsDataSource {
  Future<List<StreamingPlatformModel>> loadPlatforms();
}

class PlatformsDataSourceImpl implements PlatformsDataSource {
  @override
  Future<List<StreamingPlatformModel>> loadPlatforms() async {
    final jsonString = await rootBundle.loadString(MediaResources.platFormsData);
    final jsonList = json.decode(jsonString) as List;
    final platforms = jsonList
        .map(
          (dataMap) => StreamingPlatformModel.fromMap(
            dataMap as DataMap,
          ),
        )
        .toList();
    return platforms;
  }
}
