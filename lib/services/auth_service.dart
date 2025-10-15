import 'package:customer_maxx_crm/models/user.dart';
import 'package:customer_maxx_crm/utils/shared_pref_utils.dart';

class AuthService {
  // Mock users for demonstration
  static final List<User> _users = [
    User(
      id: 1,
      name: 'Pranali',
      email: 'admin@admin.com',
      role: 'Admin',
      password: 'admin123',
    ),
    User(
      id: 2,
      name: 'gayatri',
      email: 'lead@lead.com',
      role: 'Lead Manager',
      password: 'lead123',
    ),
    User(
      id: 3,
      name: 'shrikant',
      email: 'ba@ba.com',
      role: 'BA Specialist',
      password: 'baspe123',
    ),
    User(
      id: 4,
      name: 'achal',
      email: 'achal@lead.com',
      role: 'Lead Manager',
      password: 'achal123',
    ),
    User(
      id: 5,
      name: 'Nikita',
      email: 'nikita@ba.com',
      role: 'BA Specialist',
      password: 'nikita123',
    ),
  ];

  static User? currentUser;

  // Initialize the service by checking for saved user data
  static Future<void> init() async {
    currentUser = await SharedPrefUtils.getUser();
  }

  // Login method
  Future<Map<String, dynamic>> login(String email, String password, String role) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Find user with matching email
    final emailUser = _users.firstWhere(
      (u) => u.email == email,
      orElse: () => User(id: -1, name: '', email: '', role: '', password: ''),
    );
    
    if (emailUser.id == -1) {
      return {
        'success': false,
        'error': 'User not found. Please check your email.',
        'user': null,
      };
    }
    
    // Check password
    if (emailUser.password != password) {
      return {
        'success': false,
        'error': 'Incorrect password. Please try again.',
        'user': null,
      };
    }
    
    // Check role
    if (emailUser.role != role) {
      return {
        'success': false,
        'error': 'Role mismatch. Please select the correct role.',
        'user': null,
      };
    }
    
    currentUser = emailUser;
    // Save user data to SharedPreferences
    await SharedPrefUtils.saveUser(emailUser);
    return {
      'success': true,
      'error': null,
      'user': emailUser,
    };
  }

  // Registration method
  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Check if email already exists
    final existingUser = _users.firstWhere(
      (u) => u.email == email,
      orElse: () => User(id: -1, name: '', email: '', role: '', password: ''),
    );
    
    if (existingUser.id != -1) {
      return {
        'success': false,
        'error': 'Email already exists. Please use a different email.',
        'user': null,
      };
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
    return {
      'success': true,
      'error': null,
      'user': newUser,
    };
  }

  // Logout method
  Future<void> logout() async {
    currentUser = null;
    // Clear user data from SharedPreferences
    await SharedPrefUtils.clearUserData();
  }

  // Get current user
  User? getCurrentUser() {
    return currentUser;
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await SharedPrefUtils.isLoggedIn();
  }
}