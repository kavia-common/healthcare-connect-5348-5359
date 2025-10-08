import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

// PUBLIC_INTERFACE
/// API service for making HTTP requests to the backend
/// Handles authentication headers and error responses
class ApiService {
  late final String baseUrl;
  String? _token;

  ApiService() {
    baseUrl = dotenv.env['BACKEND_BASE_URL'] ?? 'http://localhost:3001';
  }

  // PUBLIC_INTERFACE
  /// Initialize the API service by loading environment variables and stored tokens
  /// This should be called before making any API requests
  Future<void> initialize() async {
    // Ensure dotenv is loaded (it should already be loaded in main.dart)
    if (!dotenv.isInitialized) {
      await dotenv.load(fileName: ".env");
    }
    
    // Load stored authentication token if available
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString(StorageKeys.token);
    if (storedToken != null) {
      _token = storedToken;
    }
  }

  // PUBLIC_INTERFACE
  /// Set the authentication token for API requests
  void setToken(String? token) {
    _token = token;
  }

  // PUBLIC_INTERFACE
  /// Get headers with authentication token if available
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // PUBLIC_INTERFACE
  /// Make a GET request
  Future<http.Response> get(String endpoint, {bool requiresAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .get(
            uri,
            headers: _getHeaders(includeAuth: requiresAuth),
          )
          .timeout(const Duration(seconds: AppConstants.networkTimeout));
      await _handleUnauthorized(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUBLIC_INTERFACE
  /// Make a POST request
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .post(
            uri,
            headers: _getHeaders(includeAuth: requiresAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: AppConstants.networkTimeout));
      await _handleUnauthorized(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUBLIC_INTERFACE
  /// Make a PATCH request
  Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .patch(
            uri,
            headers: _getHeaders(includeAuth: requiresAuth),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: AppConstants.networkTimeout));
      await _handleUnauthorized(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUBLIC_INTERFACE
  /// Make a DELETE request
  Future<http.Response> delete(String endpoint, {bool requiresAuth = true}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http
          .delete(
            uri,
            headers: _getHeaders(includeAuth: requiresAuth),
          )
          .timeout(const Duration(seconds: AppConstants.networkTimeout));
      await _handleUnauthorized(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Handle 401 unauthorized responses
  Future<void> _handleUnauthorized(http.Response response) async {
    if (response.statusCode == 401) {
      // Clear stored token on unauthorized
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.token);
      await prefs.remove(StorageKeys.userId);
      await prefs.remove(StorageKeys.userRole);
      _token = null;
    }
  }
}
