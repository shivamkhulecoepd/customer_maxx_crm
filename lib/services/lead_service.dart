import 'dart:developer';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/lead.dart';
import '../models/dropdown_data.dart';
import '../models/user.dart';

class LeadService {
  final ApiClient apiClient;
  
  LeadService(this.apiClient);
  
  // Get all leads with optional filtering and pagination
  Future<List<Lead>> getAllLeads({String? status, int page = 1, int limit = 10}) async {
    try {
      final queryParameters = {
        if (status != null) 'status': status,
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      final response = await apiClient.get(
        ApiEndpoints.getLeads,
        queryParameters: queryParameters,
        authenticated: true,
      );
      
      if (response['status'] == 'success') {
        final leads = (response['leads'] as List)
            .map((leadJson) => Lead.fromJson(leadJson))
            .toList();
        
        return leads;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch leads');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Create a new lead
  Future<Map<String, dynamic>> createLead(Lead lead) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.createLead,
        lead.toJson(),
        authenticated: true,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Update an existing lead
  Future<Map<String, dynamic>> updateLead(Lead lead) async {
    try {
      final response = await apiClient.put(
        ApiEndpoints.updateLead,
        lead.toJson(),
        authenticated: true,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete a lead
  Future<Map<String, dynamic>> deleteLead(int leadId) async {
    try {
      final response = await apiClient.delete(
        ApiEndpoints.deleteLead,
        queryParameters: {'id': leadId.toString()},
        authenticated: true,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get lead history
  Future<List<LeadHistory>> getLeadHistory(int leadId) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getLeadHistory,
        queryParameters: {'lead_id': leadId.toString()},
        authenticated: true,
      );
      
      if (response['status'] == 'success') {
        final history = (response['history'] as List)
            .map((historyJson) => LeadHistory.fromJson(historyJson))
            .toList();
        
        return history;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch lead history');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Import leads from CSV file
  Future<Map<String, dynamic>> importLeads(Map<String, dynamic> formData) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.importLeads,
        formData,
        authenticated: true,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Export leads to CSV file
  Future<Map<String, dynamic>> exportLeads() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.exportLeads,
        authenticated: true,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Update fee information for a lead
  Future<Map<String, dynamic>> updateFee(int leadId, int discount, double installment1, double installment2) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.updateFee,
        {
          'id': leadId,
          'discount': discount,
          'installment1': installment1,
          'installment2': installment2,
        },
        authenticated: true,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Update feedback for a lead
  Future<Map<String, dynamic>> updateFeedback(int leadId, String feedback) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.updateFeedback,
        {
          'id': leadId,
          'feedback': feedback,
        },
        authenticated: true,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Update status for a lead
  Future<Map<String, dynamic>> updateStatus(int leadId, String status) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.updateStatus,
        {
          'id': leadId,
          'status': status,
        },
        authenticated: true,
      );
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get lead managers for dropdown
  Future<List<UserRole>> getLeadManagers() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getLeadManagers,
        authenticated: true,
      );
      
      if (response['status'] == 'success') {
        final leadManagers = (response['lead_managers'] as List)
            .map((managerJson) => UserRole.fromJson(managerJson))
            .toList();
        
        return leadManagers;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch lead managers');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Get BA specialists for dropdown
  Future<List<UserRole>> getBASpecialists() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getBASpecialists,
        authenticated: true,
      );
      
      if (response['status'] == 'success') {
        final baSpecialists = (response['ba_specialists'] as List)
            .map((specialistJson) => UserRole.fromJson(specialistJson))
            .toList();
        
        return baSpecialists;
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch BA specialists');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Get all dropdown data in one call
  Future<DropdownData> getDropdownData() async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.getDropdownData,
        authenticated: true,
      );
      
      if (response['status'] == 'success') {
        return DropdownData.fromJson(response['dropdown_data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch dropdown data');
      }
    } catch (e) {
      rethrow;
    }
  }
}