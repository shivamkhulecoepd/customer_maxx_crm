import 'package:customer_maxx_crm/utils/api_service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/users/users_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/dashboard/dashboard_bloc.dart';
import 'package:customer_maxx_crm/blocs/lead_manager_dashboard/lead_manager_dashboard_bloc.dart';
import 'package:customer_maxx_crm/blocs/manager_dashboard/manager_dashboard_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/screens/common/splash_screen.dart';
import 'package:customer_maxx_crm/screens/auth/auth_screen.dart';
import 'package:customer_maxx_crm/screens/admin/admin_dashboard.dart';
import 'package:customer_maxx_crm/screens/lead_manager/lead_manager_dashboard.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/ba_specialist_dashboard.dart';
import 'package:customer_maxx_crm/screens/manager/manager_dashboard.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';

import 'package:customer_maxx_crm/blocs/notifications/notification_bloc.dart';
import 'package:customer_maxx_crm/blocs/notifications/notification_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize services through ServiceLocator
  await ServiceLocator.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
        BlocProvider<LeadsBloc>(create: (context) => LeadsBloc()),
        BlocProvider<UsersBloc>(create: (context) => UsersBloc()),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc()..add(LoadTheme()),
        ),
        BlocProvider<DashboardBloc>(create: (context) => DashboardBloc()),
        BlocProvider<LeadManagerDashboardBloc>(
          create: (context) => LeadManagerDashboardBloc(),
        ),
        BlocProvider<ManagerDashboardBloc>(
          create: (context) => ManagerDashboardBloc(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) =>
              NotificationBloc(ServiceLocator.notificationService),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // Load initial notifications immediately
          context.read<NotificationBloc>().add(const LoadNotifications());
          // Then start polling for updates
          context.read<NotificationBloc>().add(StartNotificationPolling());
        } else if (state is Unauthenticated) {
          context.read<NotificationBloc>().add(StopNotificationPolling());
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'CustomerMax CRM',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeState.themeMode,
            debugShowCheckedModeBanner: false,
            home: const ModernSplashScreen(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // For AuthLoading state, we don't show a generic loading screen
        // Instead, we let the AuthScreen handle loading states on the buttons
        // This provides a better UX as the user can see which action is loading

        if (authState is Authenticated) {
          final userRole = authState.user?.role;
          if (userRole != null) {
            switch (userRole) {
              case 'admin':
                return const ModernAdminDashboard();
              case 'bde':
                return const ModernLeadManagerDashboard();
              case 'operations':
                return const ModernBASpecialistDashboard();
              case 'manager':
                return const ModernManagerDashboard();
              default:
                // Handle case where role names don't match exactly
                if (userRole.toLowerCase().contains('admin')) {
                  return const ModernAdminDashboard();
                } else if (userRole.toLowerCase().contains('bde') ||
                    userRole.toLowerCase().contains('lead')) {
                  return const ModernLeadManagerDashboard();
                } else if (userRole.toLowerCase().contains('operations') ||
                    userRole.toLowerCase().contains('ba') ||
                    userRole.toLowerCase().contains('specialist')) {
                  return const ModernBASpecialistDashboard();
                } else if (userRole.toLowerCase().contains('manager')) {
                  return const ModernManagerDashboard();
                } else {
                  return const ModernAuthScreen(authMode: AuthMode.login);
                }
            }
          }
        }
        return const ModernAuthScreen(authMode: AuthMode.login);
      },
    );
  }
}
