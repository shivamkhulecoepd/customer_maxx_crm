import 'package:customer_maxx_crm/models/user.dart';

class UserService {
  // Mock users for demonstration (same as in auth_service)
  static final List<User> _users = [
    User(
      id: 1,
      name: 'Admin',
      email: 'admin@admin.com',
      role: 'Admin',
      password: 'admin123',
    ),
    User(
      id: 2,
      name: 'Lead Manager',
      email: 'lead@lead.com',
      role: 'Lead Manager',
      password: 'lead123',
    ),
    User(
      id: 3,
      name: 'BA Specialist',
      email: 'ba@ba.com',
      role: 'BA Specialist',
      password: 'baspe123',
    ),
  ];

  // Get all users
  Future<List<User>> getAllUsers() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    return List.from(_users);
  }

  // Add a new user
  Future<bool> addUser(User user) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Check if email already exists
    final existingUser = _users.firstWhere(
      (u) => u.email == user.email,
      orElse: () => User(id: -1, name: '', email: '', role: '', password: ''),
    );
    
    if (existingUser.id != -1) {
      return false; // Email already exists
    }
    
    // Assign a new ID
    final newId = _users.map((u) => u.id).reduce((a, b) => a > b ? a : b) + 1;
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
    await Future.delayed(Duration(milliseconds: 500));
    
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      return true;
    }
    return false;
  }

  // Delete a user
  Future<bool> deleteUser(int id) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Prevent deleting the current user
    if (AuthService.currentUser != null && AuthService.currentUser!.id == id) {
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

// We need to import AuthService here, but to avoid circular dependency,
// we'll define a simple mock of the current user
class AuthService {
  static User? currentUser;
}