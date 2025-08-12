import 'package:flutter/foundation.dart';

class Logger {
  static const bool _isLoggingEnabled = kDebugMode;
  
  static void debug(String message) {
    if (_isLoggingEnabled) {
      // ignore: avoid_print
      print('[DEBUG] $message');
    }
  }
  
  static void info(String message) {
    if (_isLoggingEnabled) {
      // ignore: avoid_print
      print('[INFO] $message');
    }
  }
  
  static void warning(String message) {
    if (_isLoggingEnabled) {
      // ignore: avoid_print
      print('[WARNING] $message');
    }
  }
  
  static void error(String message) {
    if (_isLoggingEnabled) {
      // ignore: avoid_print
      print('[ERROR] $message');
    }
  }
  
  static void logEvent(String event, [Map<String, dynamic>? properties]) {
    if (_isLoggingEnabled) {
      final propertiesString = properties != null ? properties.toString() : '';
      // ignore: avoid_print
      print('[EVENT] $event $propertiesString');
    }
  }
}