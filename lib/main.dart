import 'package:customer_maxx_crm/utils/api_service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/users/users_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/screens/splash_screen.dart';
import 'package:customer_maxx_crm/screens/auth/auth_screen.dart';
import 'package:customer_maxx_crm/screens/admin/admin_dashboard.dart';
import 'package:customer_maxx_crm/screens/lead_manager/lead_manager_dashboard.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/ba_specialist_dashboard.dart';
// import 'package:customer_maxx_crm/services/auth_service.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';
import 'package:customer_maxx_crm/screens/dummy_data_example.dart';
import 'package:customer_maxx_crm/screens/comprehensive_table_example.dart';
import 'package:customer_maxx_crm/screens/table_examples_menu.dart';

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
          title: 'CustomerMaxx CRM',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeState.themeMode,
          debugShowCheckedModeBanner: false,
          home: const ModernSplashScreen(),
          routes: {
            '/dummy-data-example': (context) => const DummyDataExampleScreen(),
            '/comprehensive-table-example': (context) => const ComprehensiveTableExample(),
            '/table-examples': (context) => const TableExamplesMenu(),
          },
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
              case 'lead_manager':
                return const ModernLeadManagerDashboard();
              case 'ba_specialist':
                return const ModernBASpecialistDashboard();
              default:
                // Handle case where role names don't match exactly
                if (userRole.toLowerCase().contains('admin')) {
                  return const ModernAdminDashboard();
                } else if (userRole.toLowerCase().contains('lead')) {
                  return const ModernLeadManagerDashboard();
                } else if (userRole.toLowerCase().contains('ba') || userRole.toLowerCase().contains('specialist')) {
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