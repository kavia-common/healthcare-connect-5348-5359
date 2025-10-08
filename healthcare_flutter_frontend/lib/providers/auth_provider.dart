import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _auth;
  bool _loading = false;
  bool _initialized = false;
  Map<String, dynamic>? _user;

  AuthProvider(this._auth);

  bool get isLoading => _loading;
  bool get isInitialized => _initialized;
  bool get isAuthenticated => _user != null;
  String get role => (_user?['role'] as String?) ?? 'patient';
  String? get userEmail => _user?['email'] as String?;
  String? get userId => _user?['id'] as String?;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  Future<void> initialize() async {
    /** Load token if any, fetch current user, and set initialized flag. */
    if (_initialized) return;
    _setLoading(true);
    try {
      final token = await _auth.getToken();
      if (token != null && token.isNotEmpty) {
        _user = await _auth.me();
      }
    } catch (_) {
      _user = null;
    } finally {
      _initialized = true;
      _setLoading(false);
    }
  }

  // PUBLIC_INTERFACE
  Future<bool> login(String email, String password) async {
    /** Perform login. Returns true on success. */
    _setLoading(true);
    try {
      await _auth.login(email: email, password: password);
      _user = await _auth.me();
      notifyListeners();
      return _user != null;
    } finally {
      _setLoading(false);
    }
  }

  // PUBLIC_INTERFACE
  Future<bool> register({required String email, required String password, String? fullName, String role = 'patient'}) async {
    /** Register user. Returns true on success. */
    _setLoading(true);
    try {
      await _auth.register(email: email, password: password, fullName: fullName, role: role);
      return true;
    } finally {
      _setLoading(false);
    }
  }

  // PUBLIC_INTERFACE
  Future<void> logout() async {
    /** Clear token and user state. */
    await _auth.logout();
    _user = null;
    notifyListeners();
  }
}
