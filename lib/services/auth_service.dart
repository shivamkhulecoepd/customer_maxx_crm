import 'package:customer_maxx_crm/models/user.dart';

class AuthService {
  // Mock users for demonstration
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
      password: 'ba123',
    ),
  ];

  static User? currentUser;

  // Login method
  Future<User?> login(String email, String password, String role) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Find user with matching credentials
    final user = _users.firstWhere(
      (u) => u.email == email && u.password == password && u.role == role,
      orElse: () => User(id: -1, name: '', email: '', role: '', password: ''),
    );
    
    if (user.id != -1) {
      currentUser = user;
      return user;
    }
    
    return null;
  }

  // Registration method
  Future<bool> register(String name, String email, String password, String role) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Check if email already exists
    final existingUser = _users.firstWhere(
      (u) => u.email == email,
      orElse: () => User(id: -1, name: '', email: '', role: '', password: ''),
    );
    
    if (existingUser.id != -1) {
      return false; // Email already exists
    }
    
    // Add new user
    final newUser = User(
      id: _users.length + 1,
      name: name,
      email: email,
      role: role,
      password: password,
    );
    
    _users.add(newUser);
    return true;
  }

  // Logout method
  void logout() {
    currentUser = null;
  }

  // Get current user
  User? getCurrentUser() {
    return currentUser;
  }
}