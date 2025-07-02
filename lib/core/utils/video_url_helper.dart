import 'package:flutter/material.dart';

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

  static String extractDailymotionVideoId(String url) {
    final regExp = RegExp(r'dailymotion\.com\/video\/([^_?&#/]+)');
    final match = regExp.firstMatch(url);
    return match?.group(1) ?? '';
  }

  static String extractTedVideoId(String url) {
    final regex = RegExp(r'ted\.com/talks/([^/?#]+)');
    final match = regex.firstMatch(url);
    return match != null ? match.group(1) ?? '' : '';
  }

  static String getEmbedUrl(String url, String platformName) {
    debugPrint('getEmbedUrl called for $platformName -> $url');
    if (platformName.toLowerCase().contains('youtube')) {
      final id = extractYoutubeVideoId(url);
      return 'https://www.youtube.com/embed/$id?modestbranding=1&controls=1&rel=0';
    } else if (platformName.toLowerCase().contains('vimeo')) {
      final id = extractVimeoVideoId(url);
      return 'https://player.vimeo.com/video/$id';
    } else if (platformName.toLowerCase().contains('dailymotion')) {
      final id = extractDailymotionVideoId(url);
      return 'https://www.dailymotion.com/embed/video/$id';
      // return 'assets/html/dailymotion_player.html?id=$id';
    } else if (platformName == 'ted') {
      final id = extractTedVideoId(url);
      if (id.isNotEmpty) {
        return 'assets/html/ted_embed.html?id=$id';
      }
    }

    // fallback: return original if no match
    return url;
  }
}
