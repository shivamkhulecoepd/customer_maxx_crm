import 'package:customer_maxx_crm/models/lead.dart';

class LeadService {
  // Mock leads for demonstration
  static final List<Lead> _leads = [
    Lead(
      id: 1,
      date: DateTime(2023, 1, 1),
      name: 'ameet',
      phone: '1234567890',
      email: 'ameet@gmail.com',
      leadManager: 'active',
      status: 'New',
      feedback: '',
    ),
    Lead(
      id: 2,
      date: DateTime(2023, 1, 2),
      name: 'john doe',
      phone: '0987654321',
      email: 'john@example.com',
      leadManager: 'active',
      status: 'Follow Up',
      feedback: '',
    ),
    Lead(
      id: 3,
      date: DateTime(2023, 1, 3),
      name: 'jane',
      phone: '1122334455',
      email: 'jane@example.com',
      leadManager: 'active',
      status: 'Closed',
      feedback: '',
    ),
    Lead(
      id: 4,
      date: DateTime(2023, 1, 4),
      name: 'alice',
      phone: '6677889900',
      email: 'alice@example.com',
      leadManager: 'active',
      status: 'New',
      feedback: '',
    ),
    Lead(
      id: 5,
      date: DateTime(2023, 1, 5),
      name: 'bob',
      phone: '5544332211',
      email: 'bob@example.com',
      leadManager: 'active',
      status: 'Follow Up',
      feedback: '',
    ),
    Lead(
      id: 6,
      date: DateTime(2023, 1, 6),
      name: 'charlie',
      phone: '9988776655',
      email: 'charlie@example.com',
      leadManager: 'active',
      status: 'New',
      feedback: '',
    ),
    Lead(
      id: 7,
      date: DateTime(2023, 1, 7),
      name: 'david',
      phone: '4433221100',
      email: 'david@example.com',
      leadManager: 'active',
      status: 'Closed',
      feedback: '',
    ),
    Lead(
      id: 8,
      date: DateTime(2023, 1, 8),
      name: 'eve',
      phone: '7766554433',
      email: 'eve@example.com',
      leadManager: 'active',
      status: 'Follow Up',
      feedback: '',
    ),
    Lead(
      id: 9,
      date: DateTime(2023, 9, 30),
      name: 'Alex',
      phone: '1234567890',
      email: 'alex@example.com',
      leadManager: 'active',
      status: 'Active',
      feedback: 'Good',
      education: '10+ years',
      experience: 'High',
      location: 'Pune',
      orderBy: 'Asc',
      assignedBy: 'Admin',
    ),
  ];

  // Get all leads
  Future<List<Lead>> getAllLeads() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    return List.from(_leads);
  }

  // Get leads by status
  Future<List<Lead>> getLeadsByStatus(String status) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    if (status == 'All') {
      return List.from(_leads);
    }
    return _leads.where((lead) => lead.status == status).toList();
  }

  // Add a new lead
  Future<bool> addLead(Lead lead) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // Assign a new ID
    final newId = _leads.map((l) => l.id).reduce((a, b) => a > b ? a : b) + 1;
    final newLead = Lead(
      id: newId,
      date: lead.date,
      name: lead.name,
      phone: lead.phone,
      email: lead.email,
      leadManager: lead.leadManager,
      status: lead.status,
      feedback: lead.feedback,
      education: lead.education,
      experience: lead.experience,
      location: lead.location,
      orderBy: lead.orderBy,
      assignedBy: lead.assignedBy,
    );
    
    _leads.add(newLead);
    return true;
  }

  // Update a lead
  Future<bool> updateLead(Lead lead) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    final index = _leads.indexWhere((l) => l.id == lead.id);
    if (index != -1) {
      _leads[index] = lead;
      return true;
    }
    return false;
  }

  // Delete a lead
  Future<bool> deleteLead(int id) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    final index = _leads.indexWhere((l) => l.id == id);
    if (index != -1) {
      _leads.removeAt(index);
      return true;
    }
    return false;
  }

  // Filter leads based on criteria
  Future<List<Lead>> filterLeads({
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
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    List<Lead> filteredLeads = List.from(_leads);
    
    if (name != null && name.isNotEmpty) {
      filteredLeads = filteredLeads.where((l) => l.name.toLowerCase().contains(name.toLowerCase())).toList();
    }
    
    if (phone != null && phone.isNotEmpty) {
      filteredLeads = filteredLeads.where((l) => l.phone.contains(phone)).toList();
    }
    
    if (email != null && email.isNotEmpty) {
      filteredLeads = filteredLeads.where((l) => l.email.toLowerCase().contains(email.toLowerCase())).toList();
    }
    
    if (education != null && education.isNotEmpty) {
      filteredLeads = filteredLeads.where((l) => l.education.toLowerCase().contains(education.toLowerCase())).toList();
    }
    
    if (experience != null && experience.isNotEmpty) {
      filteredLeads = filteredLeads.where((l) => l.experience.toLowerCase().contains(experience.toLowerCase())).toList();
    }
    
    if (location != null && location.isNotEmpty) {
      filteredLeads = filteredLeads.where((l) => l.location.toLowerCase().contains(location.toLowerCase())).toList();
    }
    
    if (status != null && status.isNotEmpty && status != 'All') {
      filteredLeads = filteredLeads.where((l) => l.status == status).toList();
    }
    
    if (feedback != null && feedback.isNotEmpty) {
      filteredLeads = filteredLeads.where((l) => l.feedback.toLowerCase().contains(feedback.toLowerCase())).toList();
    }
    
    if (orderBy != null && orderBy.isNotEmpty) {
      filteredLeads = filteredLeads.where((l) => l.orderBy.toLowerCase().contains(orderBy.toLowerCase())).toList();
    }
    
    if (assignedBy != null && assignedBy.isNotEmpty) {
      filteredLeads = filteredLeads.where((l) => l.assignedBy.toLowerCase().contains(assignedBy.toLowerCase())).toList();
    }
    
    return filteredLeads.cast<Lead>();
  }
}