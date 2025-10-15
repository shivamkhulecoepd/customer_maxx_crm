import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/models/user.dart';
import 'package:customer_maxx_crm/services/user_service.dart';

class UsersProvider with ChangeNotifier {
  final UserService _userService = UserService();
  List<User> _users = [];
  bool _isLoading = false;

  List<User> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userService.getAllUsers();
    } catch (e) {
      // Handle error
      debugPrint('Error fetching users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addUser(User user) async {
    try {
      final success = await _userService.addUser(user);
      if (success) {
        _users.add(user);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error adding user: $e');
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      final success = await _userService.updateUser(user);
      if (success) {
        final index = _users.indexWhere((u) => u.id == user.id);
        if (index != -1) {
          _users[index] = user;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final success = await _userService.deleteUser(id);
      if (success) {
        _users.removeWhere((u) => u.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }
}