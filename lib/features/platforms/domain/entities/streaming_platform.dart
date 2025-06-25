import 'package:equatable/equatable.dart';

/// Represents a streaming platform entity in the platforms domain.
class StreamingPlatform extends Equatable {
  const StreamingPlatform({
    required this.name,
    required this.logoPath,
    required this.logoDarkPath,
    required this.isDRMProtected,
    required this.defaultUrl,
    required this.playScript,
    required this.pauseScript,
    required this.currentTimeScript,
    this.packageName,
    this.deeplinkUrl,
    this.appstoreUrl,
    this.playStoreUrl,
  });

  /// Empty Constructor for [StreamingPlatform].
  ///
  /// This helps when writing unit tests.
  const StreamingPlatform.empty()
      : this(
          name: '',
          logoPath: '',
          logoDarkPath: '',
          isDRMProtected: false,
          defaultUrl: '',
          playScript: '',
          pauseScript: '',
          currentTimeScript: '',
        );

  /// The display name of the platform (e.g., Netflix, Hulu).
  final String name;

  /// The asset path for the platform's logo image.
  final String logoPath;

  /// The asset path for the platform's darkmode logo image.
  final String logoDarkPath;

  /// Whether the platform uses DRM protection (e.g., Netflix, Disney+).
  final bool isDRMProtected;

  /// Default fallback URL for accessing the platform via browser.
  final String defaultUrl;

  final String playScript;

  final String pauseScript;

  final String currentTimeScript;

  /// Android package name (used to check installation or launch the app).
  final String? packageName;

  /// Deeplink URL used to open the app natively, if supported.
  final String? deeplinkUrl;

  /// Apple App Store URL for installing the app on iOS devices.
  final String? appstoreUrl;

  /// Google Play Store URL for installing the app on Android devices.
  final String? playStoreUrl;

  @override
  String toString() {
    return '''
    StreamingPlatform(
       name: $name, 
       logoPath: $logoPath, 
       isDRMProtected: $isDRMProtected, 
       defaultUrl: $defaultUrl, 
       packageName: $packageName,
       deeplinkUrl: $deeplinkUrl,
       appstoreUrl: $appstoreUrl,
       playStoreUrl: $playStoreUrl,
    ) ''';
  }

  @override
  List<Object?> get props => [
        name,
        logoPath,
        isDRMProtected,
        packageName,
        deeplinkUrl,
        defaultUrl,
        appstoreUrl,
        playStoreUrl,
      ];
}
