class VideoUrlHelper {
  static String extractYoutubeVideoId(String url) {
    final regExp = RegExp(
      r'(?:v=|\/)([0-9A-Za-z_-]{11})(?:[&?]|$)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }

  static String extractVimeoVideoId(String url) {
    final regExp = RegExp(
      r'vimeo\.com/(?:.*?/)?(\d+)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }

  static String getEmbedUrl(String url, String platformName) {
    if (platformName.toLowerCase().contains('youtube')) {
      final id = extractYoutubeVideoId(url);
      return 'https://www.youtube.com/embed/$id?modestbranding=1&controls=1&rel=0';
    } else if (platformName.toLowerCase().contains('vimeo')) {
      final id = extractVimeoVideoId(url);
      return 'https://player.vimeo.com/video/$id';
    }

    // fallback: return original if no match
    return url;
  }
}
