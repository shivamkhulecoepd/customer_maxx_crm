abstract class LeadManagerDashboardEvent {}

class LoadLeadManagerStats extends LeadManagerDashboardEvent {
  final int? managerId;

  LoadLeadManagerStats({this.managerId});
}