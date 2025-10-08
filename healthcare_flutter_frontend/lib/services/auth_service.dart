import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  // PUBLIC_INTERFACE
  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    /** Login with email and password, persist JWT, and return token map. */
    final resp = await _client.post('/auth/login_json', auth: false, body: {'email': email, 'password': password});
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final token = data['access_token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Invalid token received');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      return data;
    } else {
      throw Exception('Login failed (${resp.statusCode}): ${resp.body}');
    }
  }

  // PUBLIC_INTERFACE
  Future<Map<String, dynamic>> register({required String email, required String password, String? fullName, String role = 'patient'}) async {
    /** Register a new user. Returns created user JSON. Does not auto-login. */
    final resp = await _client.post('/auth/register', auth: false, body: {
      'email': email,
      'password': password,
      'full_name': fullName,
      'role': role,
    });
    if (resp.statusCode == 201) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Registration failed (${resp.statusCode}): ${resp.body}');
    }
  }

  // PUBLIC_INTERFACE
  Future<Map<String, dynamic>?> me() async {
    /** Fetch current authenticated user's profile (email, role, id). */
    final resp = await _client.get('/auth/me', auth: true);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else if (resp.statusCode == 401) {
      return null;
    } else {
      throw Exception('Failed to load profile (${resp.statusCode})');
    }
  }

  // PUBLIC_INTERFACE
  Future<void> logout() async {
    /** Clear the persisted JWT to logout the user. */
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  // PUBLIC_INTERFACE
  Future<String?> getToken() async {
    /** Retrieve the persisted JWT token, or null if not available. */
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }
}
