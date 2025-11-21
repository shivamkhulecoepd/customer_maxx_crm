import 'package:equatable/equatable.dart';

abstract class ManagerDashboardEvent extends Equatable {
  const ManagerDashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadManagerStats extends ManagerDashboardEvent {
  final int? managerId;

  const LoadManagerStats({this.managerId});

  @override
  List<Object> get props => [if (managerId != null) managerId!];
}
