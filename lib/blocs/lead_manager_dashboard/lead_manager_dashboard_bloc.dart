import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/api_service_locator.dart';
import 'lead_manager_dashboard_event.dart';
import 'lead_manager_dashboard_state.dart';

class LeadManagerDashboardBloc
    extends Bloc<LeadManagerDashboardEvent, LeadManagerDashboardState> {
  LeadManagerDashboardBloc() : super(LeadManagerDashboardInitial()) {
    on<LoadLeadManagerStats>(_onLoadLeadManagerStats);
  }

  Future<void> _onLoadLeadManagerStats(
    LoadLeadManagerStats event,
    Emitter<LeadManagerDashboardState> emit,
  ) async {
    emit(LeadManagerDashboardLoading());
    try {
      if (!ServiceLocator.isInitialized) {
        await ServiceLocator.init();
      }

      final dashboardService = ServiceLocator.dashboardService;
      developer.log('Fetching lead manager stats for managerId: ${event.managerId}');
      final stats = await dashboardService.getLeadManagerStats(
        managerId: event.managerId,
      );
      developer.log('Received lead manager stats: ${stats.totalLeads} total leads');
      developer.log('Status counts: ${stats.statusCounts}');
      emit(LeadManagerDashboardLoaded(stats));
      developer.log('Emitted LeadManagerDashboardLoaded state');
    } catch (e) {
      developer.log('Error fetching lead manager stats: $e');
      emit(LeadManagerDashboardError(e.toString()));
    }
  }
}