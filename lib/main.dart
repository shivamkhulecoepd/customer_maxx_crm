import 'package:customer_maxx_crm/utils/api_service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/users/users_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/dashboard/dashboard_bloc.dart';
import 'package:customer_maxx_crm/blocs/lead_manager_dashboard/lead_manager_dashboard_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/screens/splash_screen.dart';
import 'package:customer_maxx_crm/screens/auth/auth_screen.dart';
import 'package:customer_maxx_crm/screens/admin/admin_dashboard.dart';
import 'package:customer_maxx_crm/screens/lead_manager/lead_manager_dashboard.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/ba_specialist_dashboard.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize services through ServiceLocator
  await ServiceLocator.init();
  
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<LeadsBloc>(
          create: (context) => LeadsBloc(),
        ),
        BlocProvider<UsersBloc>(
          create: (context) => UsersBloc(),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc()..add(LoadTheme()),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(),
        ),
        BlocProvider<LeadManagerDashboardBloc>(
          create: (context) => LeadManagerDashboardBloc(),
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
    return BlocBuilder<ThemeBloc, ThemeState>(
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
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Show loading while initializing
        if (authState is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }
        
        // Navigate based on authentication status
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
              default:
                // Handle case where role names don't match exactly
                if (userRole.toLowerCase().contains('admin')) {
                  return const ModernAdminDashboard();
                } else if (userRole.toLowerCase().contains('bde') || userRole.toLowerCase().contains('lead')) {
                  return const ModernLeadManagerDashboard();
                } else if (userRole.toLowerCase().contains('operations') || userRole.toLowerCase().contains('ba') || userRole.toLowerCase().contains('specialist')) {
                  return const ModernBASpecialistDashboard();
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