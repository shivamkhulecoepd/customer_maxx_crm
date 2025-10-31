import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user.dart';
// import '../models/dropdown_data.dart';

class UserService {
  final ApiClient apiClient;
  
  UserService(this.apiClient);
  
  // Get all users with pagination
  Future<List<User>> getAllUsers({int page = 1, int limit = 10}) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      final response = await apiClient.get(
        ApiEndpoints.getUsers,
        queryParameters: queryParameters,
        authenticated: true,
      );
      
      if (response['status'] == 'success') {
        final users = (response['users'] as List)
            .map((userJson) => User.fromJson(userJson))
            .toList();
        
        return users;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch users');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Get a specific user by ID
  Future<User> getUserById(int userId) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getUser,
        queryParameters: {'id': userId.toString()},
        authenticated: true,
      );
      
      if (response['status'] == 'success') {
        return User.fromJson(response['user']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch user');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Create a new user
  Future<Map<String, dynamic>> createUser(User user, String password) async {
    try {
      final userData = user.toJson();
      userData['password'] = password;
      
      final response = await apiClient.post(
        ApiEndpoints.createUser,
        userData,
        authenticated: true,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Update an existing user
  Future<Map<String, dynamic>> updateUser(User user, {String? password}) async {
    try {
      final userData = user.toJson();
      if (password != null && password.isNotEmpty) {
        userData['password'] = password;
      }
      
      final response = await apiClient.put(
        ApiEndpoints.updateUser,
        userData,
        authenticated: true,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete a user
  Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await apiClient.delete(
        ApiEndpoints.deleteUser,
        queryParameters: {'id': userId.toString()},
        authenticated: true,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all user roles for dropdown
  Future<List<UserRole>> getUserRoles() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getUserRoles,
        authenticated: true,
      );
      
      if (response['status'] == 'success') {
        final roles = (response['roles'] as List)
            .map((roleJson) => UserRole.fromJson(roleJson))
            .toList();
        
        return roles;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch user roles');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Get registration roles for dropdown
  Future<List<UserRole>> getRegistrationRoles() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getRegistrationRoles,
        authenticated: true,
      );
      
      if (response['status'] == 'success') {
        final roles = (response['roles'] as List)
            .map((roleJson) => UserRole.fromJson(roleJson))
            .toList();
        
        return roles;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch registration roles');
      }
    } catch (e) {
      rethrow;
    }
  }
}