import 'package:customer_maxx_crm/models/user.dart';

class UserService {
  // Mock users for demonstration (same as in auth_service)
  static final List<User> _users = [
    const User(
      id: '1',
      name: 'Admin',
      email: 'admin@admin.com',
      role: 'Admin',
      password: 'admin123',
    ),
    const User(
      id: '2',
      name: 'Lead Manager',
      email: 'lead@lead.com',
      role: 'Lead Manager',
      password: 'lead123',
    ),
    const User(
      id: '3',
      name: 'BA Specialist',
      email: 'ba@ba.com',
      role: 'BA Specialist',
      password: 'baspe123',
    ),
  ];

  // Get all users
  Future<List<User>> getAllUsers() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_users);
  }

  // Add a new user
  Future<bool> addUser(User user) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Check if email already exists
    final existingUser = _users.firstWhere(
      (u) => u.email == user.email,
      orElse: () => const User(id: '-1', name: '', email: '', role: '', password: ''),
    );
    
    if (existingUser.id != '-1') {
      return false; // Email already exists
    }
    
    // Assign a new ID
    final maxId = _users.map((u) => int.parse(u.id)).reduce((a, b) => a > b ? a : b);
    final newId = (maxId + 1).toString();
    final newUser = User(
      id: newId,
      name: user.name,
      email: user.email,
      role: user.role,
      password: user.password,
    );
    
    _users.add(newUser);
    return true;
  }

  // Update a user
  Future<bool> updateUser(User user) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      return true;
    }
    return false;
  }

  // Delete a user
  Future<bool> deleteUser(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Prevent deleting the current user
    if (_AuthServiceRef.currentUser != null && _AuthServiceRef.currentUser!.id == id.toString()) {
      return false;
    }
    
    final index = _users.indexWhere((u) => u.id == id);
    if (index != -1) {
      _users.removeAt(index);
      return true;
    }
    return false;
  }
}

// Simple reference to avoid circular dependency
class _AuthServiceRef {
  static User? currentUser;
}