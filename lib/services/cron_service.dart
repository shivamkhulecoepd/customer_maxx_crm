import 'dart:developer';
import 'package:customer_maxx_crm/api/api_client.dart';
import 'package:customer_maxx_crm/api/api_endpoints.dart';

class CronService {
  final ApiClient apiClient;

  CronService(this.apiClient);

  Future<Map<String, dynamic>> runCron(String type) async {
    log('Running cron type: $type');

    try {
      final response = await apiClient.get(
        ApiEndpoints.runCron,
        queryParameters: {'type': type},
        authenticated: true,
      );

      log('Cron Response: $response');

      if (response['status'] == 'success') {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Cron failed');
      }
    } catch (e) {
      log('Error running cron: $e');
      rethrow;
    }
  }
}
