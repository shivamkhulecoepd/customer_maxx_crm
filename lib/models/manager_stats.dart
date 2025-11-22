class ManagerStats {
  final int totalLeads;
  final Map<String, int> statusCounts;
  final List<Map<String, dynamic>> recentLeads;
  final Map<String, dynamic>? debugInfo;

  ManagerStats({
    required this.totalLeads,
    required this.statusCounts,
    required this.recentLeads,
    this.debugInfo,
  });

  factory ManagerStats.fromJson(Map<String, dynamic> json) {
    final statusCountsJson =
        json['status_counts'] as Map<String, dynamic>? ?? {};
    final statusCounts = statusCountsJson.map(
      (key, value) => MapEntry(key, int.tryParse(value.toString()) ?? 0),
    );

    final recentLeadsJson = json['recent_leads'] as List<dynamic>? ?? [];
    final recentLeads = recentLeadsJson
        .map((e) => e as Map<String, dynamic>)
        .toList();

    return ManagerStats(
      totalLeads: int.tryParse(json['total_leads'].toString()) ?? 0,
      statusCounts: statusCounts,
      recentLeads: recentLeads,
      debugInfo: json['debug_info'] as Map<String, dynamic>?,
    );
  }
}
