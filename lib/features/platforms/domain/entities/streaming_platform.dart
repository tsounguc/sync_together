import 'package:equatable/equatable.dart';

class StreamingPlatform extends Equatable {
  const StreamingPlatform({
    required this.name,
    required this.logoPath,
    required this.isDRMProtected,
    required this.defaultUrl,
    this.packageName,
    this.deeplinkUrl,
    this.appstoreUrl,
    this.playStoreUrl,
  });

  StreamingPlatform.empty()
      : this(
          name: '',
          logoPath: '',
          isDRMProtected: false,
          defaultUrl: '',
        );

  final String name;
  final String logoPath;
  final bool isDRMProtected;
  final String defaultUrl;
  final String? packageName;
  final String? deeplinkUrl;
  final String? appstoreUrl;
  final String? playStoreUrl;

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
