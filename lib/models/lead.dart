class Lead {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String education;
  final String experience;
  final String location;
  final String status;
  final String feedback;
  final String createdAt;
  final String ownerName;
  final String assignedName;
  final String latestHistory;
  final int? discount;
  final double? installment1;
  final double? installment2;
  final DateTime? date;
  // Optional fields for creation
  final int? ownerId;
  final int? assignedTo;

  Lead({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.education,
    required this.experience,
    required this.location,
    required this.status,
    required this.feedback,
    required this.createdAt,
    required this.ownerName,
    required this.assignedName,
    required this.latestHistory,
    this.discount,
    this.installment1,
    this.installment2,
    this.date,
    this.ownerId,
    this.assignedTo,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert dynamic values to double
    double? _toDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        try {
          return double.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
    
    // Helper function to safely convert dynamic values to int
    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
    
    return Lead(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      education: json['education'] as String,
      experience: json['experience'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      feedback: json['feedback'] as String? ?? '',
      createdAt: json['created_at'] as String,
      ownerName: json['owner_name'] as String,
      assignedName: json['assigned_name'] as String,
      latestHistory: json['latest_history'] as String,
      discount: _toInt(json['discount']),
      installment1: _toDouble(json['installment1']),
      installment2: _toDouble(json['installment2']),
      date: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      ownerId: null, // Not returned by API
      assignedTo: null, // Not returned by API
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'education': education,
      'experience': experience,
      'location': location,
      'status': status,
      'feedback': feedback,
      'created_at': createdAt,
      'owner_name': ownerName,
      'assigned_name': assignedName,
      'latest_history': latestHistory,
      if (discount != null) 'discount': discount,
      if (installment1 != null) 'installment1': installment1.toString(),
      if (installment2 != null) 'installment2': installment2.toString(),
    };
    
    // For creation, use ID fields instead of name fields if IDs are provided
    if (ownerId != null) {
      json['owner_id'] = ownerId;
      json.remove('owner_name');
    }
    
    if (assignedTo != null) {
      json['assigned_to'] = assignedTo;
      json.remove('assigned_name');
    }
    
    return json;
  }
}

class LeadHistory {
  final String status;
  final String feedback;
  final String updatedAt;
  final String updatedBy;
  final String role;

  LeadHistory({
    required this.status,
    required this.feedback,
    required this.updatedAt,
    required this.updatedBy,
    required this.role,
  });

  factory LeadHistory.fromJson(Map<String, dynamic> json) {
    return LeadHistory(
      status: json['status'] as String,
      feedback: json['feedback'] as String,
      updatedAt: json['updated_at'] as String,
      updatedBy: json['updated_by'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'feedback': feedback,
      'updated_at': updatedAt,
      'updated_by': updatedBy,
      'role': role,
    };
  }
}
