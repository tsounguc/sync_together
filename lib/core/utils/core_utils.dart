import 'package:flutter/material.dart';
import 'package:sync_together/core/extensions/context_extension.dart';

class CoreUtils {
  const CoreUtils._();

  static void showSnackBar(
    BuildContext context,
    String message, {
    int durationInMilliSecond = 3000,
  }) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          duration: Duration(milliseconds: durationInMilliSecond),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: 20,
          ).copyWith(bottom: context.height * 0.80),
        ),
      );
  }
}
