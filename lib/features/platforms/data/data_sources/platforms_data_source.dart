import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sync_together/core/resources/media_resources.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/platforms/data/models/streaming_platform_model.dart';

/// **PlatformsDataSource Interface**
///
/// Defines the contract for loading streaming platform data
/// from local or remote sources.
///
/// This layer isolates data-fetching logic so that the repository and domain
/// layers remain agnostic to how the data is retrieved.
abstract class PlatformsDataSource {
  /// Loads the list of supported streaming platforms from a data source.
  ///
  /// - **Success:** Returns a list of [StreamingPlatformModel].
  /// - **Failure:** Throws an exception if loading or parsing fails.
  Future<List<StreamingPlatformModel>> loadPlatforms();
}

class PlatformsDataSourceImpl implements PlatformsDataSource {
  @override
  Future<List<StreamingPlatformModel>> loadPlatforms() async {
    final jsonString = await rootBundle.loadString(
      MediaResources.platFormsData,
    );
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
