class Lead {
  final String id;
  final DateTime date;
  final String name;
  final String phone;
  final String email;
  final String leadManager;
  final String status;
  final String feedback;
  final String education;
  final String experience;
  final String location;
  final String orderBy;
  final String assignedBy;
  final String discount;
  final String baSpecialist;

  const Lead({
    required this.id,
    required this.date,
    required this.name,
    required this.phone,
    required this.email,
    required this.leadManager,
    required this.status,
    required this.feedback,
    required this.education,
    required this.experience,
    required this.location,
    required this.orderBy,
    required this.assignedBy,
    required this.discount,
    required this.baSpecialist,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'].toString(),
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      leadManager: json['leadManager'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      feedback: json['feedback'] as String? ?? '',
      education: json['education'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      location: json['location'] as String? ?? '',
      orderBy: json['orderBy'] as String? ?? '',
      assignedBy: json['assignedBy'] as String? ?? '',
      discount: json['discount'] as String? ?? '',
      baSpecialist: json['baSpecialist'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'name': name,
      'phone': phone,
      'email': email,
      'leadManager': leadManager,
      'status': status,
      'feedback': feedback,
      'education': education,
      'experience': experience,
      'location': location,
      'orderBy': orderBy,
      'assignedBy': assignedBy,
      'discount': discount,
      'baSpecialist': baSpecialist,
    };
  }
}