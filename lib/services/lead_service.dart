import 'package:customer_maxx_crm/models/lead.dart';

class LeadService {
  // Mock leads for demonstration - matching the screenshots
  static final List<Lead> _leads = [
    Lead(
      id: '1',
      date: DateTime(2025, 10, 9, 6, 19),
      name: 'pranali',
      phone: '8888888889',
      email: '',
      leadManager: 'achal',
      status: 'Registered',
      feedback: '',
      education: 'MBA',
      experience: '',
      location: 'Pune',
      orderBy: '',
      assignedBy: 'Nikita',
      discount: '',
      baSpecialist: 'Nikita',
    ),
    Lead(
      id: '2',
      date: DateTime(2025, 10, 9, 5, 36),
      name: 'pranali',
      phone: '8888888800',
      email: '',
      leadManager: 'achal',
      status: 'Demo Attended',
      feedback: 'No feedback',
      education: 'MBA',
      experience: '',
      location: 'Akola',
      orderBy: '',
      assignedBy: 'Nikita',
      discount: '',
      baSpecialist: 'Nikita',
    ),
    Lead(
      id: '3',
      date: DateTime(2025, 10, 7, 6, 22),
      name: 'pranali',
      phone: '8888888888',
      email: 'p@gmail.com',
      leadManager: 'achal',
      status: 'Demo Attended',
      feedback: 'No feedback',
      education: 'MBA',
      experience: '2 years as software developer',
      location: 'Akola',
      orderBy: '',
      assignedBy: 'Nikita',
      discount: '',
      baSpecialist: 'Nikita',
    ),
    Lead(
      id: '4',
      date: DateTime(2025, 10, 7, 6, 5),
      name: 'pranali',
      phone: '9876543210',
      email: 'facilities.pune@coepd.com',
      leadManager: 'achal',
      status: 'Not Connected',
      feedback: 'No feedback',
      education: 'MBA',
      experience: '',
      location: 'Akola',
      orderBy: '',
      assignedBy: 'Nikita',
      discount: '',
      baSpecialist: 'Nikita',
    ),
    Lead(
      id: '5',
      date: DateTime(2025, 10, 5, 2, 53),
      name: 'Bhargavi',
      phone: '9999999888',
      email: 'bhargavi@gmail.com',
      leadManager: 'achal',
      status: 'Not Connected',
      feedback: 'No feedback',
      education: 'B.Com',
      experience: '10',
      location: 'Pune',
      orderBy: '',
      assignedBy: 'Nikita',
      discount: '',
      baSpecialist: 'Nikita',
    ),
    Lead(
      id: '6',
      date: DateTime(2025, 10, 5, 2, 50),
      name: 'Raju',
      phone: '9988755466',
      email: 'raju@gmail.com',
      leadManager: 'D V P Sridhar',
      status: 'Not Connected',
      feedback: 'No feedback',
      education: 'B.Tech',
      experience: '2',
      location: 'Hyderabad',
      orderBy: '',
      assignedBy: 'shrikant',
      discount: '',
      baSpecialist: 'shrikant',
    ),
    Lead(
      id: '7',
      date: DateTime(2025, 9, 30, 7, 1),
      name: 'nilesh',
      phone: '9876567890',
      email: 'nrghode491@gmail.com',
      leadManager: 'achal',
      status: 'Demo Interested',
      feedback: 'call at 4 Pm',
      education: 'MBA',
      experience: '2 years in marketing',
      location: 'Pune',
      orderBy: '',
      assignedBy: 'Nikita',
      discount: '',
      baSpecialist: 'Nikita',
    ),
    Lead(
      id: '8',
      date: DateTime(2025, 9, 30, 5, 22),
      name: 'Achal',
      phone: '9786789098',
      email: '',
      leadManager: 'achal',
      status: 'Registered',
      feedback: 'No feedback',
      education: 'BBA',
      experience: '2 years',
      location: 'Pune',
      orderBy: '',
      assignedBy: 'shrikant',
      discount: '',
      baSpecialist: 'shrikant',
    ),
    Lead(
      id: '9',
      date: DateTime(2025, 9, 30, 5, 14),
      name: 'Purva',
      phone: '9999999988',
      email: '',
      leadManager: 'achal',
      status: 'Not Connected',
      feedback: 'No feedback',
      education: '',
      experience: '',
      location: '',
      orderBy: '',
      assignedBy: 'Nikita',
      discount: '',
      baSpecialist: 'Nikita',
    ),
    Lead(
      id: '10',
      date: DateTime(2025, 9, 30, 5, 0),
      name: 'Gayatri',
      phone: '9604111799',
      email: 'gayatri@gmail.com',
      leadManager: 'achal',
      status: 'Demo Attended',
      feedback: 'she attended the demo',
      education: 'BBA',
      experience: '2 years',
      location: 'Pune',
      orderBy: '',
      assignedBy: 'Nikita',
      discount: '',
      baSpecialist: 'Nikita',
    ),
    Lead(
      id: '11',
      date: DateTime(2025, 9, 28, 5, 40),
      name: 'pranali',
      phone: '1234567890',
      email: 'p@gmail.com',
      leadManager: 'achal',
      status: 'Pending',
      feedback: 'No feedback',
      education: '',
      experience: '2 years as software developer',
      location: 'Akola',
      orderBy: '',
      assignedBy: 'Nikita',
      discount: '',
      baSpecialist: 'Nikita',
    ),
  ];

  // Get all leads
  Future<List<Lead>> getAllLeads() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_leads);
  }

  // Get leads by status
  Future<List<Lead>> getLeadsByStatus(String status) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (status == 'All' || status == '-- Filter by Status --') {
      return List.from(_leads);
    }
    return _leads.where((lead) => lead.status == status).toList();
  }

  // Add a new lead
  Future<bool> addLead(Lead lead) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Assign a new ID
    final newId = _leads.isEmpty ? '1' : (int.parse(_leads.map((l) => l.id).reduce((a, b) => int.parse(a) > int.parse(b) ? a : b)) + 1).toString();
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
      discount: lead.discount,
      baSpecialist: lead.baSpecialist,
    );
    
    _leads.add(newLead);
    return true;
  }

  // Update a lead
  Future<bool> updateLead(Lead lead) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _leads.indexWhere((l) => l.id == lead.id);
    if (index != -1) {
      _leads[index] = lead;
      return true;
    }
    return false;
  }

  // Delete a lead
  Future<bool> deleteLead(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
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
    await Future.delayed(const Duration(milliseconds: 500));
    
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
    
    if (status != null && status.isNotEmpty && status != 'All' && status != 'All Status') {
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