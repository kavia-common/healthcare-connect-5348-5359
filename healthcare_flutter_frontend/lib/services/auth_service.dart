import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

// PUBLIC_INTERFACE
/// Authentication service for login, register, and user management
/// Handles JWT token storage using shared_preferences
/// Note: For production mobile apps, consider using flutter_secure_storage for better security
class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  // PUBLIC_INTERFACE
  /// Login with email and password
  /// Returns the authenticated user on success
  Future<User> login(String email, String password) async {
    final response = await _apiService.post(
      ApiEndpoints.login,
      {'email': email, 'password': password},
      requiresAuth: false,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'] as String;
      
      // Store token
      await _saveToken(token);
      _apiService.setToken(token);
      
      // Fetch user details
      return await getCurrentUser();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Login failed');
    }
  }

  // PUBLIC_INTERFACE
  /// Register a new user
  /// Returns the created user on success
  Future<User> register({
    required String email,
    required String password,
    String? fullName,
    String role = 'patient',
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.register,
      {
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
      },
      requiresAuth: false,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data);
      
      // Auto-login after registration
      return await login(email, password);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed');
    }
  }

  // PUBLIC_INTERFACE
  /// Get current authenticated user
  Future<User> getCurrentUser() async {
    final response = await _apiService.get(ApiEndpoints.me);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data);
      
      // Store user info
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.userId, user.id);
      await prefs.setString(StorageKeys.userRole, user.role);
      
      return user;
    } else {
      throw Exception('Failed to fetch user');
    }
  }

  // PUBLIC_INTERFACE
  /// Logout and clear stored credentials
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.token);
    await prefs.remove(StorageKeys.userId);
    await prefs.remove(StorageKeys.userRole);
    _apiService.setToken(null);
  }

  // PUBLIC_INTERFACE
  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.token);
    return token != null;
  }

  // PUBLIC_INTERFACE
  /// Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(StorageKeys.token);
  }

  // Save token to shared preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StorageKeys.token, token);
  }

  // PUBLIC_INTERFACE
  /// Initialize service by loading stored token
  Future<void> initialize() async {
    final token = await getToken();
    if (token != null) {
      _apiService.setToken(token);
    }
  }
}
