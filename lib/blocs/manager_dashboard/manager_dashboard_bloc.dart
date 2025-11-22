import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/api_service_locator.dart';
import 'manager_dashboard_event.dart';
import 'manager_dashboard_state.dart';

class ManagerDashboardBloc
    extends Bloc<ManagerDashboardEvent, ManagerDashboardState> {
  ManagerDashboardBloc() : super(ManagerDashboardInitial()) {
    on<LoadManagerStats>(_onLoadManagerStats);
  }

  Future<void> _onLoadManagerStats(
    LoadManagerStats event,
    Emitter<ManagerDashboardState> emit,
  ) async {
    emit(ManagerDashboardLoading());
    try {
      if (!ServiceLocator.isInitialized) {
        await ServiceLocator.init();
      }

      final dashboardService = ServiceLocator.dashboardService;
      developer.log('Fetching manager stats for managerId: ${event.managerId}');
      final stats = await dashboardService.getManagerStats(
        managerId: event.managerId,
      );
      developer.log('stats: $stats');
      developer.log('Received manager stats: ${stats.totalLeads} total leads');
      if (stats.debugInfo != null) {
        developer.log('Debug Info: ${stats.debugInfo}');
      }
      emit(ManagerDashboardLoaded(stats));
    } catch (e) {
      developer.log('Error fetching manager stats: $e');
      emit(ManagerDashboardError(e.toString()));
    }
  }
}
