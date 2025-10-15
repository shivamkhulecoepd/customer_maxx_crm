import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/screens/auth/auth_screen.dart';
import 'package:customer_maxx_crm/screens/admin/admin_dashboard_screen.dart';
import 'package:customer_maxx_crm/screens/lead_manager/lead_manager_dashboard_screen.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/ba_specialist_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize the app after a short delay to show the splash screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Add a small delay to show the splash screen
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Trigger app initialization in the AuthBloc
    if (mounted) {
      context.read<AuthBloc>().add(AppStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Navigate based on authentication status
        if (state is Authenticated) {
          final userRole = state.user?.role;
          if (userRole != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              switch (userRole) {
                case 'Admin':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModernAdminDashboardScreen(),
                    ),
                  );
                  break;
                case 'Lead Manager':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LeadManagerDashboardScreen(),
                    ),
                  );
                  break;
                case 'BA Specialist':
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BASpecialistDashboardScreen(),
                    ),
                  );
                  break;
                default:
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuthScreen(authMode: AuthMode.login),
                    ),
                  );
              }
            });
          }
        } else if (state is Unauthenticated || state is AuthInitial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AuthScreen(authMode: AuthMode.login),
              ),
            );
          });
        } else if (state is AuthError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AuthScreen(authMode: AuthMode.login),
              ),
            );
          });
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDarkMode = themeState.isDarkMode;
          
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [
                          const Color(0xFF0097A7),
                          const Color(0xFF00838F),
                          const Color(0xFF006064),
                        ]
                      : [
                          const Color(0xFF00BCD4),
                          const Color(0xFF00ACC1),
                          const Color(0xFF0097A7),
                        ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Hero(
                      tag: 'app_logo',
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode 
                                  ? Colors.black.withValues(alpha: 0.3) 
                                  : Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.business,
                          size: 80,
                          color: isDarkMode ? const Color(0xFF00BCD4) : const Color(0xFF00BCD4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // App Name
                    const Text(
                      'CUSTOMER MAXX',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'C R M',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 5,
                        color: isDarkMode ? Colors.white70 : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Loading Indicator
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white70 : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}