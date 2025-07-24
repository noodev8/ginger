import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  /// Login user
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;
        // TODO: Store auth token in secure storage
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Login error in provider: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register user
  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
    String? phone,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.register(
        email: email,
        password: password,
        displayName: displayName,
        phone: phone,
      );
      if (user != null) {
        _currentUser = user;
        // TODO: Store auth token in secure storage
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Registration error in provider: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logout user
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      // TODO: Clear auth token from secure storage
    } catch (e) {
      if (kDebugMode) {
        print('Logout error in provider: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Initialize auth state (check for stored token on app start)
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check for stored token and validate it with server
      final user = await _authService.validateStoredToken();
      if (user != null) {
        _currentUser = user;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Auth initialization error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get current auth token
  Future<String?> getAuthToken() async {
    return await _authService.getStoredToken();
  }
}
