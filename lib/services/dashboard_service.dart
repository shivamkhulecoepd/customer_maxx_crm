import 'dart:developer' as developer;
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/dashboard_stats.dart';
import '../models/manager_stats.dart';

class DashboardService {
  final ApiClient apiClient;

  DashboardService(this.apiClient);

  // Get admin statistics
  Future<AdminStats> getAdminStats() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getAdminStats,
        authenticated: true,
      );

      if (response['status'] == 'success') {
        return AdminStats.fromJson(response['stats']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch admin stats');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get lead manager statistics
  Future<LeadManagerStats> getLeadManagerStats({int? managerId}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (managerId != null) {
        queryParameters['managerId'] = managerId.toString();
      }

      final response = await apiClient.get(
        ApiEndpoints.getLeadManagerStats,
        queryParameters: queryParameters,
        authenticated: true,
      );

      // Log the response for debugging
      developer.log('LeadManagerStats API Response: $response');

      if (response['status'] == 'success') {
        final stats = LeadManagerStats.fromJson(response['stats']);
        developer.log(
          'Parsed LeadManagerStats: ${stats.totalLeads} total leads, status counts: ${stats.statusCounts}',
        );
        return stats;
      } else {
        throw Exception(
          response['message'] ?? 'Failed to fetch lead manager stats',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get BA specialist statistics
  Future<BAStats> getBAStats() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getBAStats,
        authenticated: true,
      );

      if (response['status'] == 'success') {
        return BAStats.fromJson(response['stats']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch BA stats');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get manager statistics
  Future<ManagerStats> getManagerStats({int? managerId}) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (managerId != null) {
        queryParameters['managerId'] = managerId.toString();
      }

      final response = await apiClient.get(
        ApiEndpoints.getManagerStats,
        queryParameters: queryParameters,
        authenticated: true,
      );

      if (response['status'] == 'success') {
        return ManagerStats.fromJson(response['stats']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch manager stats');
      }
    } catch (e) {
      rethrow;
    }
  }
}
