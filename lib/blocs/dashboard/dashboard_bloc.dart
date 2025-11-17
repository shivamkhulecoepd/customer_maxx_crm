import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/api_service_locator.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadAdminStats>(_onLoadAdminStats);
  }

  Future<void> _onLoadAdminStats(
    LoadAdminStats event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      if (!ServiceLocator.isInitialized) {
        log('ServiceLocator not initialized, initializing now...');
        await ServiceLocator.init();
      }

      log('Loading admin stats...');
      final dashboardService = ServiceLocator.dashboardService;
      final stats = await dashboardService.getAdminStats();
      log('Admin stats loaded successfully');
      emit(DashboardLoaded(stats));
    } catch (e) {
      log('Error loading admin stats: $e');
      emit(DashboardError(e.toString()));
    }
  }
}
