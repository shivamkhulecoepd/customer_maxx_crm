// Example usage of the API integration in a Dart application


import 'api_client.dart';
import '../models/lead.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';
import '../services/lead_service.dart';
import '../services/user_service.dart';
import '../utils/api_constants.dart';

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
    print('Logging in...');
    
    try {
      final response = await authService.login(
        'admin@example.com',
        'password123',
        'admin',
      );
      
      print('Login successful: ${response['message']}');
    } catch (e) {
      print('Login failed: $e');
    }
  }
  
  // Example: Fetch all leads
  Future<void> fetchLeads() async {
    print('Fetching leads...');
    
    try {
      final leads = await leadService.getAllLeads();
      print('Fetched ${leads.length} leads');
      
      // Print first few leads
      for (var i = 0; i < leads.length && i < 3; i++) {
        print('Lead ${leads[i].id}: ${leads[i].name} - ${leads[i].status}');
      }
    } catch (e) {
      print('Failed to fetch leads: $e');
    }
  }
  
  // Example: Create a new lead
  Future<void> createLead() async {
    print('Creating lead...');
    
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
      print('Lead created: ${response['message']}');
    } catch (e) {
      print('Failed to create lead: $e');
    }
  }
  
  // Example: Update lead status
  Future<void> updateLeadStatus() async {
    print('Updating lead status...');
    
    try {
      final response = await leadService.updateStatus(1, 'Connected');
      print('Lead status updated: ${response['message']}');
    } catch (e) {
      print('Failed to update lead status: $e');
    }
  }
  
  // Example: Update lead feedback
  Future<void> updateLeadFeedback() async {
    print('Updating lead feedback...');
    
    try {
      final response = await leadService.updateFeedback(1, 'Customer is interested');
      print('Lead feedback updated: ${response['message']}');
    } catch (e) {
      print('Failed to update lead feedback: $e');
    }
  }
  
  // Example: Update lead fee information
  Future<void> updateLeadFee() async {
    print('Updating lead fee information...');
    
    try {
      final response = await leadService.updateFee(1, 10, 500.00, 500.00);
      print('Lead fee information updated: ${response['message']}');
    } catch (e) {
      print('Failed to update lead fee information: $e');
    }
  }
  
  // Example: Fetch dropdown data
  Future<void> fetchDropdownData() async {
    print('Fetching dropdown data...');
    
    try {
      final dropdownData = await leadService.getDropdownData();
      print('Fetched ${dropdownData.leadManagers.length} lead managers and '
          '${dropdownData.baSpecialists.length} BA specialists');
      
      // Print lead managers
      print('Lead Managers:');
      for (var manager in dropdownData.leadManagers) {
        print('  ${manager.name} (ID: ${manager.id})');
      }
      
      // Print BA specialists
      print('BA Specialists:');
      for (var specialist in dropdownData.baSpecialists) {
        print('  ${specialist.name} (ID: ${specialist.id})');
      }
    } catch (e) {
      print('Failed to fetch dropdown data: $e');
    }
  }
  
  // Example: Fetch user roles
  Future<void> fetchUserRoles() async {
    print('Fetching user roles...');
    
    try {
      final roles = await userService.getUserRoles();
      print('Fetched ${roles.length} user roles');
      
      // Print roles
      for (var role in roles) {
        print('  ${role.name} (ID: ${role.id})');
      }
    } catch (e) {
      print('Failed to fetch user roles: $e');
    }
  }
  
  // Example: Fetch admin stats
  Future<void> fetchAdminStats() async {
    print('Fetching admin stats...');
    
    try {
      final stats = await dashboardService.getAdminStats();
      print('Admin Stats:');
      print('  Total Users: ${stats.users.total}');
      print('  Total Leads: ${stats.leads.total}');
      print('  Total Registrations: ${stats.registrations.total}');
      print('  Total Demos: ${stats.demos.total}');
    } catch (e) {
      print('Failed to fetch admin stats: $e');
    }
  }
  
  // Example: Fetch lead manager stats
  Future<void> fetchLeadManagerStats() async {
    print('Fetching lead manager stats...');
    
    try {
      final stats = await dashboardService.getLeadManagerStats(managerId: 1);
      print('Lead Manager Stats:');
      print('  Status Counts: ${stats.statusCounts}');
      print('  Recent Leads: ${stats.recentLeads.length}');
    } catch (e) {
      print('Failed to fetch lead manager stats: $e');
    }
  }
  
  // Example: Fetch BA stats
  Future<void> fetchBAStats() async {
    print('Fetching BA stats...');
    
    try {
      final stats = await dashboardService.getBAStats();
      print('BA Stats:');
      print('  Total Leads: ${stats.totalLeads}');
      print('  Registered Leads: ${stats.registeredLeads}');
      print('  Conversion Rate: ${stats.conversionRate}%');
    } catch (e) {
      print('Failed to fetch BA stats: $e');
    }
  }
  
  // Example: Import leads
  Future<void> importLeads() async {
    print('Importing leads...');
    
    try {
      // This is a simplified example - in a real app, you would read actual file data
      final formData = {
        'file': 'csv_data_here' // This would be actual CSV file data
      };
      
      final response = await leadService.importLeads(formData);
      print('Leads imported: ${response['message']}');
    } catch (e) {
      print('Failed to import leads: $e');
    }
  }
  
  // Example: Export leads
  Future<void> exportLeads() async {
    print('Exporting leads...');
    
    try {
      final response = await leadService.exportLeads();
      print('Leads exported: ${response['message']}');
    } catch (e) {
      print('Failed to export leads: $e');
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