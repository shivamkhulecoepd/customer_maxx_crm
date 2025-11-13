import '../../models/dashboard_stats.dart';

abstract class LeadManagerDashboardState {}

class LeadManagerDashboardInitial extends LeadManagerDashboardState {}

class LeadManagerDashboardLoading extends LeadManagerDashboardState {}

class LeadManagerDashboardLoaded extends LeadManagerDashboardState {
  final LeadManagerStats stats;

  LeadManagerDashboardLoaded(this.stats);
}

class LeadManagerDashboardError extends LeadManagerDashboardState {
  final String message;

  LeadManagerDashboardError(this.message);
}