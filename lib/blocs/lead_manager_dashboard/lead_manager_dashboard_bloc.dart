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
      final stats = await dashboardService.getLeadManagerStats(
        managerId: event.managerId,
      );
      emit(LeadManagerDashboardLoaded(stats));
    } catch (e) {
      emit(LeadManagerDashboardError(e.toString()));
    }
  }
}