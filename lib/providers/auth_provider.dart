import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/models/user.dart';
import 'package:customer_maxx_crm/services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  final AuthService _authService = AuthService();
  bool _isInitialized = false;

  AuthProvider() {
    // Initialize the auth service and check if user is already logged in
    _initialize();
  }

  // Initialize the provider by checking for saved user data
  Future<void> _initialize() async {
    try {
      await AuthService.init();
      _user = AuthService.currentUser;
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _isInitialized = true;
      notifyListeners();
    }
  }

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isInitialized => _isInitialized;

  Future<bool> login(String email, String password, String role) async {
    try {
      final user = await _authService.login(email, password, role);
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String role) async {
    try {
      final success = await _authService.register(name, email, password, role);
      if (success) {
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    } catch (e) {
      // Even if logout fails, clear local state
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }
}