import 'dart:io' show Platform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  // PUBLIC_INTERFACE
  static String backendBaseUrl() {
    /** Read the backend base URL from the .env file (BACKEND_BASE_URL). */
    return dotenv.env['BACKEND_BASE_URL']?.trim() ?? '';
  }

  // PUBLIC_INTERFACE
  static String effectiveBaseUrl() {
    /**
     * Returns a base URL usable for the current platform.
     * - On Android emulators, remap localhost to 10.0.2.2
     * - Ensures no trailing slash.
     */
    var url = backendBaseUrl();
    if (url.isEmpty) return url;
    if (Platform.isAndroid && (url.contains('localhost') || url.contains('127.0.0.1'))) {
      url = url.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
    }
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }
}
