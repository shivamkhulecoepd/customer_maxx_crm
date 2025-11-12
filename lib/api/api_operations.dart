// Example usage of the API integration in a Dart application


import 'api_client.dart';
import '../models/lead.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';
import '../services/lead_service.dart';
import '../services/user_service.dart';
import '../utils/api_constants.dart';
import 'dart:developer' as developer;

class ApiOperations {
  late ApiClient apiClient;
  late AuthService authService;
  late LeadService leadService;
  late UserService userService;
  late DashboardService dashboardService;
  
  ApiOperations() {
    _initializeServices();
  }
  
  // Initialize all services
  void _initializeServices() {
    apiClient = ApiClient(baseUrl: ApiConstants.baseUrl);
    authService = AuthService(apiClient);
    leadService = LeadService(apiClient);
    userService = UserService(apiClient);
    dashboardService = DashboardService(apiClient);
    
    // Initialize auth service
    authService.init();
  }
  
  // Example: User login
  Future<void> login() async {
    developer.log('Logging in...');
    
    try {
      final response = await authService.login(
        'admin@example.com',
        'password123',
        'admin',
      );
      
      developer.log('Login successful: ${response['message']}');
    } catch (e) {
      developer.log('Login failed: $e');
    }
  }
  
  // Example: Fetch all leads
  Future<void> fetchLeads() async {
    developer.log('Fetching leads...');
    
    try {
      final leads = await leadService.getAllLeadsNoPagination();
      developer.log('Fetched ${leads.length} leads');
      
      // Print first few leads
      for (var i = 0; i < leads.length && i < 3; i++) {
        developer.log('Lead ${leads[i].id}: ${leads[i].name} - ${leads[i].status}');
      }
    } catch (e) {
      developer.log('Failed to fetch leads: $e');
    }
  }
  
  // Example: Create a new lead
  Future<void> createLead() async {
    developer.log('Creating lead...');
    
    try {
      final newLead = Lead(
        id: 0, // Will be assigned by the server
        name: 'John Doe',
        phone: '+1234567890',
        email: 'john@example.com',
        education: 'Bachelor\'s Degree',
        experience: '5 years',
        location: 'New York',
        status: 'Not Connected',
        feedback: 'New lead',
        createdAt: DateTime.now().toIso8601String(),
        ownerName: 'Admin',
        assignedName: 'Unassigned',
        latestHistory: 'New lead created',
      );
      
      final response = await leadService.createLead(newLead);
      developer.log('Lead created: ${response['message']}');
    } catch (e) {
      developer.log('Failed to create lead: $e');
    }
  }
  
  // Example: Update lead status
  Future<void> updateLeadStatus() async {
    developer.log('Updating lead status...');
    
    try {
      final response = await leadService.updateStatus(1, 'Connected');
      developer.log('Lead status updated: ${response['message']}');
    } catch (e) {
      developer.log('Failed to update lead status: $e');
    }
  }
  
  // Example: Update lead feedback
  Future<void> updateLeadFeedback() async {
    developer.log('Updating lead feedback...');
    
    try {
      final response = await leadService.updateFeedback(1, 'Customer is interested');
      developer.log('Lead feedback updated: ${response['message']}');
    } catch (e) {
      developer.log('Failed to update lead feedback: $e');
    }
  }
  
  // Example: Update lead fee information
  Future<void> updateLeadFee() async {
    developer.log('Updating lead fee information...');
    
    try {
      final response = await leadService.updateFee(1, 10, 500.00, 500.00);
      developer.log('Lead fee information updated: ${response['message']}');
    } catch (e) {
      developer.log('Failed to update lead fee information: $e');
    }
  }
  
  // Example: Fetch dropdown data
  Future<void> fetchDropdownData() async {
    developer.log('Fetching dropdown data...');
    
    try {
      final dropdownData = await leadService.getDropdownData();
      developer.log('Fetched ${dropdownData.leadManagers.length} lead managers and '
          '${dropdownData.baSpecialists.length} BA specialists');
      
      // Print lead managers
      developer.log('Lead Managers:');
      for (var manager in dropdownData.leadManagers) {
        developer.log('  ${manager.name} (ID: ${manager.id})');
      }
      
      // Print BA specialists
      developer.log('BA Specialists:');
      for (var specialist in dropdownData.baSpecialists) {
        developer.log('  ${specialist.name} (ID: ${specialist.id})');
      }
    } catch (e) {
      developer.log('Failed to fetch dropdown data: $e');
    }
  }
  
  // Example: Fetch user roles
  Future<void> fetchUserRoles() async {
    developer.log('Fetching user roles...');
    
    try {
      final roles = await userService.getUserRoles();
      developer.log('Fetched ${roles.length} user roles');
      
      // Print roles
      for (var role in roles) {
        developer.log('  ${role.name} (ID: ${role.id})');
      }
    } catch (e) {
      developer.log('Failed to fetch user roles: $e');
    }
  }
  
  // Example: Fetch admin stats
  Future<void> fetchAdminStats() async {
    developer.log('Fetching admin stats...');
    
    try {
      final stats = await dashboardService.getAdminStats();
      developer.log('Admin Stats:');
      developer.log('  Total Users: ${stats.users.total}');
      developer.log('  Total Leads: ${stats.leads.total}');
      developer.log('  Total Registrations: ${stats.registrations.total}');
      developer.log('  Total Demos: ${stats.demos.total}');
    } catch (e) {
      developer.log('Failed to fetch admin stats: $e');
    }
  }
  
  // Example: Fetch lead manager stats
  Future<void> fetchLeadManagerStats() async {
    developer.log('Fetching lead manager stats...');
    
    try {
      final stats = await dashboardService.getLeadManagerStats(managerId: 1);
      developer.log('Lead Manager Stats:');
      developer.log('  Status Counts: ${stats.statusCounts}');
      developer.log('  Recent Leads: ${stats.recentLeads.length}');
    } catch (e) {
      developer.log('Failed to fetch lead manager stats: $e');
    }
  }
  
  // Example: Fetch BA stats
  Future<void> fetchBAStats() async {
    developer.log('Fetching BA stats...');
    
    try {
      final stats = await dashboardService.getBAStats();
      developer.log('BA Stats:');
      developer.log('  Total Leads: ${stats.totalLeads}');
      developer.log('  Registered Leads: ${stats.registeredLeads}');
      developer.log('  Conversion Rate: ${stats.conversionRate}%');
    } catch (e) {
      developer.log('Failed to fetch BA stats: $e');
    }
  }
  
  // Example: Import leads
  Future<void> importLeads() async {
    developer.log('Importing leads...');
    
    try {
      // This is a simplified example - in a real app, you would read actual file data
      final formData = {
        'file': 'csv_data_here' // This would be actual CSV file data
      };
      
      final response = await leadService.importLeads(formData);
      developer.log('Leads imported: ${response['message']}');
    } catch (e) {
      developer.log('Failed to import leads: $e');
    }
  }
  
  // Example: Export leads
  Future<void> exportLeads() async {
    developer.log('Exporting leads...');
    
    try {
      final response = await leadService.exportLeads();
      developer.log('Leads exported: ${response['message']}');
    } catch (e) {
      developer.log('Failed to export leads: $e');
    }
  }
}

// Usage example
void main() async {
  final example = ApiOperations();
  
  // Run examples
  await example.login();
  await example.fetchDropdownData();
  await example.fetchUserRoles();
  await example.fetchLeads();
  await example.createLead();
  await example.updateLeadStatus();
  await example.updateLeadFeedback();
  await example.updateLeadFee();
  await example.fetchAdminStats();
  await example.fetchLeadManagerStats();
  await example.fetchBAStats();
  await example.importLeads();
  await example.exportLeads();
}