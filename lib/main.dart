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
import 'package:customer_maxx_crm/services/auth_service.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  
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
              case 'Admin':
                return const ModernAdminDashboard();
              case 'Lead Manager':
                return const ModernLeadManagerDashboard();
              case 'BA Specialist':
                return const ModernBASpecialistDashboard();
              default:
                return const ModernAuthScreen(authMode: AuthMode.login);
            }
          }
        }
        return const ModernAuthScreen(authMode: AuthMode.login);
      },
    );
  }
}