import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:customer_maxx_crm/services/lead_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
      debugPrint('Error fetching leads: $e');
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
      debugPrint('Error fetching leads by status: $e');
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
      debugPrint('Error adding lead: $e');
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
      debugPrint('Error updating lead: $e');
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
      debugPrint('Error deleting lead: $e');
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
      debugPrint('Error filtering leads: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a search method for general search functionality
  Future<void> searchLeads(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      // For now, we'll filter by name, phone, or email
      // In a real implementation, this would call a search API
      List<Lead> allLeads = await _leadService.getAllLeads();
      if (query.isEmpty) {
        _leads = allLeads;
      } else {
        _leads = allLeads.where((lead) {
          return lead.name.toLowerCase().contains(query.toLowerCase()) ||
              lead.phone.contains(query) ||
              lead.email.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    } catch (e) {
      debugPrint('Error searching leads: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a method to filter leads by date
  Future<void> filterLeadsByDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Lead> allLeads = await _leadService.getAllLeads();
      _leads = allLeads.where((lead) {
        return lead.date.year == date.year &&
            lead.date.month == date.month &&
            lead.date.day == date.day;
      }).toList();
    } catch (e) {
      debugPrint('Error filtering leads by date: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add the missing exportCSV method with improved error handling
  Future<bool> exportCSV() async {
    try {
      // Create CSV headers
      List<List<dynamic>> rows = [];
      
      // Add header row
      rows.add([
        'ID', 'Date', 'Name', 'Phone', 'Email', 'Lead Manager',
        'Status', 'Feedback', 'Education', 'Experience', 'Location', 'Order By',
        'Assigned By', 'Discount', 'First Installment', 'Second Installment', 'Final Fee'
      ]);
      
      // Add data rows
      for (var lead in _leads) {
        rows.add([
          lead.id,
          lead.date.toIso8601String(),
          lead.name,
          lead.phone,
          lead.email,
          lead.leadManager,
          lead.status,
          lead.feedback,
          lead.education,
          lead.experience,
          lead.location,
          lead.orderBy,
          lead.assignedBy,
          lead.discount ?? '',
          lead.firstInstallment ?? '',
          lead.secondInstallment ?? '',
          lead.finalFee ?? '',
        ]);
      }
      
      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(rows);
      
      // Get the directory for saving files
      Directory? directory;
      try {
        directory = await getApplicationDocumentsDirectory();
      } catch (e) {
        debugPrint('Error getting application documents directory: $e');
        // Fallback to temporary directory
        directory = await getTemporaryDirectory();
      }
      
      // Save to file
      final file = File('${directory.path}/leads_export.csv');
      await file.writeAsString(csv);
      
      debugPrint('CSV exported to: ${file.path}');
      return true;
    } catch (e) {
      debugPrint('Error exporting CSV: $e');
      return false;
    }
  }

  // Add the missing importCSV method with improved error handling
  Future<bool> importCSV() async {
    try {
      // Pick a CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      
      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        final input = await file.readAsString();
        
        // Parse CSV
        List<List<dynamic>> rows = const CsvToListConverter().convert(input);
        
        // Skip header row and process data
        bool hasError = false;
        for (int i = 1; i < rows.length; i++) {
          try {
            var row = rows[i];
            if (row.length >= 17) {
              final lead = Lead(
                id: row[0] is int ? row[0] : int.tryParse(row[0].toString()) ?? 0,
                date: DateTime.tryParse(row[1].toString()) ?? DateTime.now(),
                name: row[2].toString(),
                phone: row[3].toString(),
                email: row[4].toString(),
                leadManager: row[5].toString(),
                status: row[6].toString(),
                feedback: row[7].toString(),
                education: row[8].toString(),
                experience: row[9].toString(),
                location: row[10].toString(),
                orderBy: row[11].toString(),
                assignedBy: row[12].toString(),
                discount: row[13].toString(),
                firstInstallment: row[14] is num ? row[14].toDouble() : double.tryParse(row[14].toString()),
                secondInstallment: row[15] is num ? row[15].toDouble() : double.tryParse(row[15].toString()),
                finalFee: row[16] is num ? row[16].toDouble() : double.tryParse(row[16].toString()),
              );
              
              // Add lead to the list
              await _leadService.addLead(lead);
              _leads.add(lead);
            }
          } catch (e) {
            debugPrint('Error processing row $i: $e');
            hasError = true;
          }
        }
        
        notifyListeners();
        debugPrint('CSV imported successfully${hasError ? ' with some errors' : ''}');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error importing CSV: $e');
      return false;
    }
  }

  // Add the missing deleteSelected method with improved efficiency
  Future<bool> deleteSelected(List<int> selectedLeadIds) async {
    try {
      bool allSuccess = true;
      for (int id in selectedLeadIds) {
        bool success = await deleteLead(id);
        if (!success) {
          allSuccess = false;
        }
      }
      
      if (allSuccess) {
        debugPrint('All selected leads deleted successfully');
      } else {
        debugPrint('Some leads could not be deleted');
      }
      
      return allSuccess;
    } catch (e) {
      debugPrint('Error deleting selected leads: $e');
      return false;
    }
  }
}