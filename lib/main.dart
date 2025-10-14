import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_maxx_crm/providers/auth_provider.dart';
import 'package:customer_maxx_crm/providers/leads_provider.dart';
import 'package:customer_maxx_crm/providers/users_provider.dart';
import 'package:customer_maxx_crm/providers/theme_provider.dart';
import 'package:customer_maxx_crm/screens/auth/login_screen.dart';
import 'package:customer_maxx_crm/screens/admin/admin_dashboard_screen.dart';
import 'package:customer_maxx_crm/screens/lead_manager/lead_manager_dashboard_screen.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/ba_specialist_dashboard_screen.dart';
import 'package:customer_maxx_crm/services/auth_service.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LeadsProvider()),
        ChangeNotifierProvider(create: (_) => UsersProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'CustomerMaxx CRM',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while initializing
        if (!authProvider.isInitialized || authProvider.status == AuthStatus.unknown) {
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
        if (authProvider.status == AuthStatus.authenticated && authProvider.user != null) {
          final userRole = authProvider.user!.role;
          switch (userRole) {
            case 'Admin':
              return const AdminDashboardScreen();
            case 'Lead Manager':
              return const LeadManagerDashboardScreen();
            case 'BA Specialist':
              return const BASpecialistDashboardScreen();
            default:
              return const LoginScreen();
          }
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}