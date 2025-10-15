import 'package:customer_maxx_crm/screens/admin/all_leads_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/screens/admin/modern_user_management_screen.dart';
import 'package:customer_maxx_crm/screens/admin/admin_dashboard_screen.dart';
import 'package:customer_maxx_crm/screens/lead_manager/add_lead_screen.dart';
import 'package:customer_maxx_crm/screens/lead_manager/view_leads_screen.dart';
import 'package:customer_maxx_crm/screens/lead_manager/lead_manager_dashboard_screen.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/registered_leads_screen.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/ba_specialist_dashboard_screen.dart';
import 'package:customer_maxx_crm/screens/settings_screen.dart';
import 'package:customer_maxx_crm/main.dart';

class ModernDrawer extends StatelessWidget {
  final String currentUserRole;
  final String currentUserName;
  final String currentUserEmail;

  const ModernDrawer({
    super.key,
    required this.currentUserRole,
    required this.currentUserName,
    required this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Modern drawer header with profile
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    currentUserName.isNotEmpty
                        ? currentUserName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentUserName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  currentUserRole,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  currentUserEmail,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Menu items with modern styling
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildModernDrawerItem(
                  context,
                  Icons.dashboard_outlined,
                  'Dashboard',
                  () {
                    Navigator.pop(context);
                    if (currentUserRole == 'Admin') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModernAdminDashboardScreen(),
                        ),
                      );
                    } else if (currentUserRole == 'Lead Manager') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const LeadManagerDashboardScreen(),
                        ),
                      );
                    } else if (currentUserRole == 'BA Specialist') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const BASpecialistDashboardScreen(),
                        ),
                      );
                    }
                  },
                  isActive: true,
                ),

                if (currentUserRole == 'Admin') ...[
                  _buildModernDrawerItem(
                    context,
                    Icons.people_outlined,
                    'User Management',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModernUserManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildModernDrawerItem(
                    context,
                    Icons.leaderboard_outlined,
                    'All Leads',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllLeadsScreen(),
                        ),
                      );
                    },
                  ),
                ] else if (currentUserRole == 'Lead Manager') ...[
                  _buildModernDrawerItem(
                    context,
                    Icons.add_outlined,
                    'Add Lead',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddLeadScreen(),
                        ),
                      );
                    },
                  ),
                  _buildModernDrawerItem(
                    context,
                    Icons.visibility_outlined,
                    'View Leads',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewLeadsScreen(),
                        ),
                      );
                    },
                  ),
                ] else if (currentUserRole == 'BA Specialist') ...[
                  _buildModernDrawerItem(
                    context,
                    Icons.app_registration_outlined,
                    'Registered Leads',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisteredLeadsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildModernDrawerItem(
                    context,
                    Icons.visibility_outlined,
                    'View Leads',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ViewLeadsScreen(),
                        ),
                      );
                    },
                  ),
                ],

                const Divider(),

                // Settings
                _buildModernDrawerItem(
                  context,
                  Icons.settings_outlined,
                  'Settings',
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ModernSettingsScreen(),
                      ),
                    );
                  },
                ),

                // Help & Support
                _buildModernDrawerItem(
                  context,
                  Icons.help_outline,
                  'Help & Support',
                  () {
                    Navigator.pop(context);
                    // Show help dialog or navigate to help screen
                  },
                ),

                // Logout
                _buildModernDrawerItem(
                  context,
                  Icons.logout,
                  'Logout',
                  () async {
                    // Show confirmation dialog
                    bool? shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Logout'),
                            ),
                          ],
                        );
                      },
                    );

                    // If user confirmed logout
                    if (shouldLogout == true) {
                      // Store context in a local variable before async operation
                      final currentContext = context;
                      // Close drawer first
                      if (currentContext.mounted) {
                        Navigator.pop(currentContext);
                      }

                      // Perform logout
                      currentContext.read<AuthBloc>().add(LogoutRequested());

                      // Clear all navigation and go to root
                      if (currentContext.mounted) {
                        Navigator.of(currentContext, rootNavigator: true)
                            .pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const AuthWrapper()),
                          (route) => false,
                        );
                      }
                    } else {
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isActive = false,
  }) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF00BCD4).withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? const Color(0xFF00BCD4)
                  : isDarkMode
                      ? Colors.white70
                      : Colors.grey[600],
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFF00BCD4)
                  : isDarkMode
                      ? Colors.white
                      : Colors.black,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}