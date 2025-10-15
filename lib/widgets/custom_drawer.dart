import 'package:customer_maxx_crm/screens/admin/all_leads_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/screens/admin/modern_user_management_screen.dart';
import 'package:customer_maxx_crm/screens/admin/admin_dashboard_screen.dart';
import 'package:customer_maxx_crm/screens/lead_manager/add_lead_screen.dart';
import 'package:customer_maxx_crm/screens/lead_manager/view_leads_screen.dart';
import 'package:customer_maxx_crm/screens/lead_manager/lead_manager_dashboard_screen.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/registered_leads_screen.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/ba_specialist_dashboard_screen.dart';
import 'package:customer_maxx_crm/screens/settings_screen.dart';
import 'package:customer_maxx_crm/main.dart';

class CustomDrawer extends StatelessWidget {
  final String currentUserRole;
  final String currentUserName;

  const CustomDrawer({
    super.key,
    required this.currentUserRole,
    required this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer header with profile
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFF00BCD4),
                  child: Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  currentUserName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentUserRole,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ModernSettingsScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'View Profile',
                    style: TextStyle(
                      color: Color(0xFF00BCD4),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, Icons.dashboard, 'Dashboard', () {
                  Navigator.pop(context);
                  // Navigate to appropriate dashboard based on role
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
                }),
                
                if (currentUserRole == 'Admin') ...[
                  _buildDrawerItem(
                    context,
                    Icons.people,
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
                  _buildDrawerItem(context, Icons.leaderboard, 'All Leads', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllLeadsScreen(),
                      ),
                    );
                  }),
                ] else if (currentUserRole == 'Lead Manager') ...[
                  _buildDrawerItem(context, Icons.add, 'Add Lead', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddLeadScreen(),
                      ),
                    );
                  }),
                  _buildDrawerItem(context, Icons.visibility, 'View Leads', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewLeadsScreen(),
                      ),
                    );
                  }),
                ] else if (currentUserRole == 'BA Specialist') ...[
                  _buildDrawerItem(
                    context,
                    Icons.app_registration,
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
                  _buildDrawerItem(context, Icons.visibility, 'View Leads', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ViewLeadsScreen(),
                      ),
                    );
                  }),
                ],
                
                const Divider(),
                
                // Settings
                _buildDrawerItem(context, Icons.settings, 'Settings', () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModernSettingsScreen(),
                    ),
                  );
                }),
                
                // Logout
                _buildDrawerItem(context, Icons.logout, 'Logout', () async {
                  // Show confirmation dialog
                  bool? shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
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
                      Navigator.of(currentContext, rootNavigator: true).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const AuthWrapper()),
                        (route) => false,
                      );
                    }
                  } else {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00BCD4)),
      title: Text(title),
      onTap: onTap,
    );
  }
}