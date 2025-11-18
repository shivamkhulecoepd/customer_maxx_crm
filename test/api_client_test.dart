import 'package:flutter_test/flutter_test.dart';
import 'package:customer_maxx_crm/api/api_client.dart';
import 'package:customer_maxx_crm/utils/api_constants.dart';

void main() {
  group('ApiClient', () {
    late ApiClient apiClient;

    setUp(() {
      apiClient = ApiClient(baseUrl: ApiConstants.baseUrl);
    });

    test('ApiClient can be instantiated with default baseUrl', () {
      final client = ApiClient();
      expect(client, isNotNull);
    });

    test('ApiClient can be instantiated with custom baseUrl and timeout', () {
      final client = ApiClient(baseUrl: 'https://test.com', timeout: 60);
      expect(client.baseUrl, equals('https://test.com'));
      expect(client.timeout, equals(60));
    });

    test('setAuthToken sets the auth token correctly', () {
      apiClient.setAuthToken('test-token');
      expect(apiClient.authToken, equals('test-token'));
    });

    test('clearAuthToken clears the auth token', () {
      apiClient.setAuthToken('test-token');
      apiClient.clearAuthToken();
      expect(apiClient.authToken, isNull);
    });
  });
}