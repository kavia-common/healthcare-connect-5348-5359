import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// PUBLIC_INTERFACE
/// Authentication provider for managing authentication state
/// Uses ChangeNotifier for reactive state management
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._authService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // PUBLIC_INTERFACE
  /// Initialize and check if user is already logged in
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _authService.initialize();
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _user = await _authService.getCurrentUser();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // PUBLIC_INTERFACE
  /// Login with email and password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _authService.login(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // PUBLIC_INTERFACE
  /// Register a new user
  Future<bool> register({
    required String email,
    required String password,
    String? fullName,
    String role = 'patient',
  }) async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        role: role,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  // PUBLIC_INTERFACE
  /// Logout current user
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
