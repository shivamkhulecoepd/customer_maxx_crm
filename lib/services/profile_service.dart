import 'dart:developer';
import 'package:customer_maxx_crm/api/api_client.dart';
import 'package:customer_maxx_crm/api/api_endpoints.dart';

class ProfileService {
  final ApiClient apiClient;

  ProfileService(this.apiClient);

  /// Fetch BA Specialist dashboard statistics
  Future<Map<String, dynamic>> fetchBADashboardStats() async {
    try {
      final response = await apiClient.get(ApiEndpoints.getBADashboard);
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch dashboard stats');
      }
    } catch (e) {
      log('Error fetching BA dashboard stats: $e');
      rethrow;
    }
  }

  /// Fetch user profile data
  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.getUser}&id=$userId');
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'data': response['data'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch user profile');
      }
    } catch (e) {
      log('Error fetching user profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.updateUser,
        {
          'id': userId,
          'fullname': name,
          'email': email,
        },
      );
      
      if (response['status'] == 'success') {
        return {
          'success': true,
          'message': response['message'],
          'data': response['data'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      log('Error updating profile: $e');
      rethrow;
    }
  }
}