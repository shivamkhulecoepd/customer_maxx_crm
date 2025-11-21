class ManagerStats {
  final int totalLeads;
  final int assignedLeads;
  final int unassignedLeads;
  final int pendingLeads;
  final int registeredLeads;
  final int notConnectedLeads;
  final int fakeLeads;
  final int totalTeamMembers;

  ManagerStats({
    required this.totalLeads,
    required this.assignedLeads,
    required this.unassignedLeads,
    required this.pendingLeads,
    required this.registeredLeads,
    required this.notConnectedLeads,
    required this.fakeLeads,
    required this.totalTeamMembers,
  });

  factory ManagerStats.fromJson(Map<String, dynamic> json) {
    return ManagerStats(
      totalLeads: int.tryParse(json['total_leads'].toString()) ?? 0,
      assignedLeads: int.tryParse(json['assigned_leads'].toString()) ?? 0,
      unassignedLeads: int.tryParse(json['unassigned_leads'].toString()) ?? 0,
      pendingLeads: int.tryParse(json['pending_leads'].toString()) ?? 0,
      registeredLeads: int.tryParse(json['registered_leads'].toString()) ?? 0,
      notConnectedLeads:
          int.tryParse(json['not_connected_leads'].toString()) ?? 0,
      fakeLeads: int.tryParse(json['fake_leads'].toString()) ?? 0,
      totalTeamMembers:
          int.tryParse(json['total_team_members'].toString()) ?? 0,
    );
  }
}
