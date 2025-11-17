import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.dart';
import '../utils/api_constants.dart';

class AuthService {
  final ApiClient apiClient;
  User? _currentUser;
  
  AuthService(this.apiClient);
  
  // Getter for current user
  User? get currentUser => _currentUser;
  
  // Login user
  Future<Map<String, dynamic>> login(String email, String password, String role) async {
    // Log the login attempt
    // ignore: avoid_print
    log('AuthService login attempt with email: $email, role: $role');
    try {
      final response = await apiClient.post(
        ApiEndpoints.login,
        {
          'email': email,
          'password': password,
          'role': role,
        },
      );
      
      // Log the response
      // ignore: avoid_print
      log('AuthService login response: $response');
      
      if (response['status'] == 'success') {
        // Save auth token and user data
        final token = response['user']['token'];
        final userData = response['user'];
        
        // Create user object using fromJson method for consistency
        _currentUser = User.fromJson({
          'id': userData['id'],
          'fullname': userData['fullname'],
          'email': '', // Email not provided in response
          'role': userData['role'],
        });
        
        // Save to secure storage
        await _saveAuthData(token, _currentUser!);
        
        // Set auth token in API client
        apiClient.setAuthToken(token);
        
        return {
          'success': true,
          'user': _currentUser,
          'message': response['message'],
        };
      } else {
        // Extract only the actual backend message without technical prefixes
        String message = response['message'] ?? 'Login failed';
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Register user
  Future<Map<String, dynamic>> register(String fullName, String email, String password, String role) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.register,
        {
          'fullname': fullName,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'message': 'Registration successful',
        };
      } else {
        // Extract only the actual backend message without technical prefixes
        String message = response['message'] ?? 'Registration failed';
        throw Exception(message);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    // Log the logout attempt
    // ignore: avoid_print
    log('AuthService logout attempt');
    // Clear authentication data
    apiClient.clearAuthToken();
    _currentUser = null;
    await _clearAuthData();
    // Log successful logout
    // ignore: avoid_print
    log('AuthService logout successful');
  }
  
  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    // Check if we have a current user and valid token
    return _currentUser != null && 
           apiClient.authToken != null && 
           apiClient.authToken!.isNotEmpty;
  }
  
  // Initialize auth service with stored token
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.authTokenKey);
    final userJson = prefs.getString(ApiConstants.userFullNameKey);
    
    if (token != null && token.isNotEmpty && userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        _currentUser = User.fromJson(userData);
        apiClient.setAuthToken(token);
      } catch (e) {
        // If there's an error parsing stored data, clear it
        await _clearAuthData();
      }
    }
  }
  
  // Save authentication data to secure storage
  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.authTokenKey, token);
    await prefs.setString(ApiConstants.userFullNameKey, jsonEncode(user.toJson()));
  }
  
  // Clear authentication data from secure storage
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.authTokenKey);
    await prefs.remove(ApiConstants.userFullNameKey);
  }
}