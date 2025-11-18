class AdminStats {
  final UserStats users;
  final LeadStats leads;
  final RegistrationStats registrations;
  final DemoStats demos;
  final MonthlyData monthlyData;

  AdminStats({
    required this.users,
    required this.leads,
    required this.registrations,
    required this.demos,
    required this.monthlyData,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      users: UserStats.fromJson(json['users']),
      leads: LeadStats.fromJson(json['leads']),
      registrations: RegistrationStats.fromJson(json['registrations']),
      demos: DemoStats.fromJson(json['demos']),
      monthlyData: MonthlyData.fromJson(json['monthly_data']),
    );
  }
}

class UserStats {
  final int total;
  final int leadManagers;
  final int baSpecialists;

  UserStats({
    required this.total,
    required this.leadManagers,
    required this.baSpecialists,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      total: json['total'] as int,
      leadManagers: json['lead_managers'] as int,
      baSpecialists: json['ba_specialists'] as int,
    );
  }
}

class LeadStats {
  final int total;
  final int daily;
  final int weekly;
  final int monthly;

  LeadStats({
    required this.total,
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  factory LeadStats.fromJson(Map<String, dynamic> json) {
    return LeadStats(
      total: json['total'] as int,
      daily: json['daily'] as int,
      weekly: json['weekly'] as int,
      monthly: json['monthly'] as int,
    );
  }
}

class RegistrationStats {
  final int total;
  final int daily;
  final int weekly;
  final int monthly;

  RegistrationStats({
    required this.total,
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  factory RegistrationStats.fromJson(Map<String, dynamic> json) {
    return RegistrationStats(
      total: json['total'] as int,
      daily: json['daily'] as int,
      weekly: json['weekly'] as int,
      monthly: json['monthly'] as int,
    );
  }
}

class DemoStats {
  final int total;
  final int daily;
  final int weekly;
  final int monthly;

  DemoStats({
    required this.total,
    required this.daily,
    required this.weekly,
    required this.monthly,
  });

  factory DemoStats.fromJson(Map<String, dynamic> json) {
    return DemoStats(
      total: json['total'] as int,
      daily: json['daily'] as int,
      weekly: json['weekly'] as int,
      monthly: json['monthly'] as int,
    );
  }
}

class MonthlyData {
  final List<String> labels;
  final List<int> shared;
  final List<int> registered;

  MonthlyData({
    required this.labels,
    required this.shared,
    required this.registered,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      labels: List<String>.from(json['labels'] as List),
      shared: List<int>.from(json['shared'] as List),
      registered: List<int>.from(json['registered'] as List),
    );
  }
}

class LeadManagerStats {
  final int totalLeads;
  final Map<String, int> statusCounts;
  final List<RecentLead> recentLeads;

  LeadManagerStats({
    required this.totalLeads,
    required this.statusCounts,
    required this.recentLeads,
  });

  factory LeadManagerStats.fromJson(Map<String, dynamic> json) {
    // Parse total leads
    final totalLeads = json['total_leads'] as int? ?? 0;
    
    // Parse status counts map
    final statusCounts = <String, int>{};
    if (json['status_counts'] is Map) {
      (json['status_counts'] as Map).forEach((key, value) {
        statusCounts[key.toString()] = value as int;
      });
    }

    // Parse recent leads list
    final recentLeads = <RecentLead>[];
    if (json['recent_leads'] is List) {
      recentLeads.addAll(
        (json['recent_leads'] as List)
            .map((item) => RecentLead.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    }

    return LeadManagerStats(
      totalLeads: totalLeads,
      statusCounts: statusCounts,
      recentLeads: recentLeads,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is LeadManagerStats &&
        other.totalLeads == totalLeads &&
        _mapsEqual(other.statusCounts, statusCounts) &&
        _listsEqual(other.recentLeads, recentLeads);
  }

  @override
  int get hashCode => Object.hash(totalLeads, statusCounts, recentLeads);

  // Helper method to compare maps
  bool _mapsEqual(Map<String, int> map1, Map<String, int> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }

  // Helper method to compare lists
  bool _listsEqual(List<RecentLead> list1, List<RecentLead> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }
    return true;
  }
}

class RecentLead {
  final String name;
  final String email;
  final String phone;
  final String status;
  final String createdAt;

  RecentLead({
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.createdAt,
  });

  factory RecentLead.fromJson(Map<String, dynamic> json) {
    return RecentLead(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is RecentLead &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.status == status &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(name, email, phone, status, createdAt);
}

class BAStats {
  final int totalLeads;
  final int registeredLeads;
  final double conversionRate;

  BAStats({
    required this.totalLeads,
    required this.registeredLeads,
    required this.conversionRate,
  });

  factory BAStats.fromJson(Map<String, dynamic> json) {
    return BAStats(
      totalLeads: json['total_leads'] as int,
      registeredLeads: json['registered_leads'] as int,
      conversionRate: (json['conversion_rate'] as num).toDouble(),
    );
  }
}