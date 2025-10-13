class Lead {
  final int id;
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
  final double? discount;
  final double? firstInstallment;
  final double? secondInstallment;
  final double? finalFee;

  Lead({
    required this.id,
    required this.date,
    required this.name,
    required this.phone,
    required this.email,
    required this.leadManager,
    required this.status,
    required this.feedback,
    this.education = '',
    this.experience = '',
    this.location = '',
    this.orderBy = '',
    this.assignedBy = '',
    this.discount,
    this.firstInstallment,
    this.secondInstallment,
    this.finalFee,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      leadManager: json['leadManager'] as String,
      status: json['status'] as String,
      feedback: json['feedback'] as String,
      education: json['education'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      location: json['location'] as String? ?? '',
      orderBy: json['orderBy'] as String? ?? '',
      assignedBy: json['assignedBy'] as String? ?? '',
      discount: (json['discount'] as num?)?.toDouble(),
      firstInstallment: (json['firstInstallment'] as num?)?.toDouble(),
      secondInstallment: (json['secondInstallment'] as num?)?.toDouble(),
      finalFee: (json['finalFee'] as num?)?.toDouble(),
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
      'firstInstallment': firstInstallment,
      'secondInstallment': secondInstallment,
      'finalFee': finalFee,
    };
  }
}