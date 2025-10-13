import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:customer_maxx_crm/services/lead_service.dart';

class LeadsProvider with ChangeNotifier {
  final LeadService _leadService = LeadService();
  List<Lead> _leads = [];
  bool _isLoading = false;

  List<Lead> get leads => _leads;
  bool get isLoading => _isLoading;

  Future<void> fetchAllLeads() async {
    _isLoading = true;
    notifyListeners();

    try {
      _leads = await _leadService.getAllLeads();
    } catch (e) {
      // Handle error
      print('Error fetching leads: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLeadsByStatus(String status) async {
    _isLoading = true;
    notifyListeners();

    try {
      _leads = await _leadService.getLeadsByStatus(status);
    } catch (e) {
      // Handle error
      print('Error fetching leads by status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addLead(Lead lead) async {
    try {
      final success = await _leadService.addLead(lead);
      if (success) {
        _leads.add(lead);
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error adding lead: $e');
      return false;
    }
  }

  Future<bool> updateLead(Lead lead) async {
    try {
      final success = await _leadService.updateLead(lead);
      if (success) {
        final index = _leads.indexWhere((l) => l.id == lead.id);
        if (index != -1) {
          _leads[index] = lead;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      print('Error updating lead: $e');
      return false;
    }
  }

  Future<bool> deleteLead(int id) async {
    try {
      final success = await _leadService.deleteLead(id);
      if (success) {
        _leads.removeWhere((l) => l.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error deleting lead: $e');
      return false;
    }
  }

  Future<void> filterLeads({
    String? name,
    String? phone,
    String? email,
    String? education,
    String? experience,
    String? location,
    String? status,
    String? feedback,
    String? orderBy,
    String? assignedBy,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _leads = await _leadService.filterLeads(
        name: name,
        phone: phone,
        email: email,
        education: education,
        experience: experience,
        location: location,
        status: status,
        feedback: feedback,
        orderBy: orderBy,
        assignedBy: assignedBy,
      );
    } catch (e) {
      // Handle error
      print('Error filtering leads: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}