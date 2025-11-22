// Service locator for managing API services

import 'dart:developer';

import 'package:customer_maxx_crm/api/api_client.dart';
import 'package:customer_maxx_crm/services/auth_service.dart';
import 'package:customer_maxx_crm/services/dashboard_service.dart';
import 'package:customer_maxx_crm/services/lead_service.dart';
import 'package:customer_maxx_crm/services/profile_service.dart';
import 'package:customer_maxx_crm/services/user_service.dart';
import 'package:customer_maxx_crm/services/notification_service.dart';
import 'package:customer_maxx_crm/services/cron_service.dart';
import 'package:customer_maxx_crm/utils/api_constants.dart';

class ServiceLocator {
  static late ApiClient _apiClient;
  static late AuthService _authService;
  static late LeadService _leadService;
  static late UserService _userService;
  static late DashboardService _dashboardService;
  static late ProfileService _profileService;
  static late NotificationService _notificationService;
  static late CronService _cronService;

  static bool _isInitialized = false;

  // Initialize all services
  static Future<void> init() async {
    if (_isInitialized) {
      log('ServiceLocator already initialized');
      return;
    }

    log('Initializing ServiceLocator...');

    try {
      _apiClient = ApiClient(baseUrl: ApiConstants.baseUrl);
      _authService = AuthService(_apiClient);
      _leadService = LeadService(_apiClient);
      _userService = UserService(_apiClient);
      _dashboardService = DashboardService(_apiClient);
      _profileService = ProfileService(_apiClient);
      _notificationService = NotificationService(_apiClient);
      _cronService = CronService(_apiClient);

      // Initialize auth service
      await _authService.init();

      _isInitialized = true;
      log('ServiceLocator initialized successfully');
    } catch (e) {
      log('Error initializing ServiceLocator: $e');
      rethrow;
    }
  }

  // Accessor methods for services
  static AuthService get authService => _authService;
  static LeadService get leadService => _leadService;
  static UserService get userService => _userService;
  static DashboardService get dashboardService => _dashboardService;
  static ProfileService get profileService => _profileService;
  static NotificationService get notificationService => _notificationService;
  static CronService get cronService => _cronService;

  // Check if services are initialized
  static bool get isInitialized => _isInitialized;

  // Reset services (useful for testing)
  static void reset() {
    _isInitialized = false;
  }
}
