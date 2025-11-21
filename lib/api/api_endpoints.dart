class ApiEndpoints {
  // Base API path
  static const String _apiPath = '/api.php';

  // Authentication endpoints
  static const String login = '$_apiPath?action=login';
  static const String register = '$_apiPath?action=register';

  // Lead endpoints
  static const String getLeads = '$_apiPath?action=get_leads';
  static const String getBADashboard = '$_apiPath?action=get_ba_dashboard';
  static const String getRegisteredLeads =
      '$_apiPath?action=get_registered_leads';
  static const String createLead = '$_apiPath?action=create_lead';
  static const String updateLead = '$_apiPath?action=update_lead';
  static const String deleteLead = '$_apiPath?action=delete_lead';
  static const String getLeadHistory = '$_apiPath?action=get_lead_history';
  static const String importLeads = '$_apiPath?action=import_leads';
  static const String exportLeads = '$_apiPath?action=export_leads';
  static const String updateFee = '$_apiPath?action=update_fee';
  static const String updateFeedback = '$_apiPath?action=update_feedback';
  static const String updateStatus = '$_apiPath?action=update_status';
  static const String getLeadManagers = '$_apiPath?action=get_lead_managers';
  static const String getBASpecialists = '$_apiPath?action=get_ba_specialists';
  static const String getDropdownData = '$_apiPath?action=get_dropdown_data';

  // User endpoints
  static const String getUsers = '$_apiPath?action=get_users';
  static const String getUser = '$_apiPath?action=get_user';
  static const String createUser = '$_apiPath?action=create_user';
  static const String updateUser = '$_apiPath?action=update_user';
  static const String deleteUser = '$_apiPath?action=delete_user';
  static const String getUserRoles = '$_apiPath?action=get_user_roles';
  static const String getRegistrationRoles =
      '$_apiPath?action=get_registration_roles';

  // Dashboard endpoints
  static const String getAdminStats = '$_apiPath?action=get_admin_stats';
  static const String getLeadManagerStats =
      '$_apiPath?action=get_lead_manager_stats';
  static const String getBAStats = '$_apiPath?action=get_ba_stats';
  static const String getManagerStats = '$_apiPath?action=get_manager_stats';

  // Notification endpoints
  static const String getNotifications = '$_apiPath?action=get_notifications';
  static const String getUnreadCount = '$_apiPath?action=get_unread_count';
  static const String markNotificationRead =
      '$_apiPath?action=mark_notification_read';
  static const String runCron = '$_apiPath?action=run_cron';

  // Stale Leads endpoint
  static const String getStaleLeads = '$_apiPath?action=get_stale_leads';
}
