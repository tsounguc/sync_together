import 'package:flutter/services.dart';

class OverlayPermissionHandler {
  static const MethodChannel _channel = MethodChannel('overlay_permission');

  static Future<bool> requestPermission() async {
    try {
      final  granted = await _channel.invokeMethod('requestOverlayPermission');
      return granted as bool;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> checkPermission() async {
    try {
      final granted = await _channel.invokeMethod('checkOverlayPermission');
      return granted as bool;
    } catch (e) {
      return false;
    }
  }
}
