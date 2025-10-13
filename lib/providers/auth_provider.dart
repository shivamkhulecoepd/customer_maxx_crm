import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/models/user.dart';
import 'package:customer_maxx_crm/services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  final AuthService _authService = AuthService();

  AuthProvider() {
    // Check if user is already logged in
    _user = AuthService.currentUser;
    _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  AuthStatus get status => _status;
  User? get user => _user;

  Future<bool> login(String email, String password, String role) async {
    try {
      final user = await _authService.login(email, password, role);
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
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

  void logout() {
    _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}