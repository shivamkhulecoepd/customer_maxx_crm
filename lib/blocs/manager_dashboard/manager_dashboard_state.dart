import 'package:equatable/equatable.dart';
import '../../models/manager_stats.dart';

abstract class ManagerDashboardState extends Equatable {
  const ManagerDashboardState();

  @override
  List<Object> get props => [];
}

class ManagerDashboardInitial extends ManagerDashboardState {}

class ManagerDashboardLoading extends ManagerDashboardState {}

class ManagerDashboardLoaded extends ManagerDashboardState {
  final ManagerStats stats;

  const ManagerDashboardLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class ManagerDashboardError extends ManagerDashboardState {
  final String message;

  const ManagerDashboardError(this.message);

  @override
  List<Object> get props => [message];
}
