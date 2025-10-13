import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_maxx_crm/providers/auth_provider.dart';
import 'package:customer_maxx_crm/screens/admin/user_management_screen.dart';
import 'package:customer_maxx_crm/screens/admin/all_leads_screen.dart';
import 'package:customer_maxx_crm/screens/admin/admin_dashboard_screen.dart';
import 'package:customer_maxx_crm/screens/lead_manager/add_lead_screen.dart';
import 'package:customer_maxx_crm/screens/lead_manager/view_leads_screen.dart';
import 'package:customer_maxx_crm/screens/lead_manager/lead_manager_dashboard_screen.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/registered_leads_screen.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/ba_specialist_dashboard_screen.dart';

class CustomDrawer extends StatelessWidget {
  final String currentUserRole;
  final String currentUserName;

  const CustomDrawer({
    Key? key,
    required this.currentUserRole,
    required this.currentUserName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3), // Blue color
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentUserName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  currentUserRole,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  Icons.dashboard,
                  'Dashboard',
                  () {
                    Navigator.pop(context);
                    // Navigate to appropriate dashboard based on role
                    if (currentUserRole == 'Admin') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminDashboardScreen(),
                        ),
                      );
                    } else if (currentUserRole == 'Lead Manager') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeadManagerDashboardScreen(),
                        ),
                      );
                    } else if (currentUserRole == 'BA Specialist') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BASpecialistDashboardScreen(),
                        ),
                      );
                    }
                  },
                ),
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
                          builder: (context) => const UserManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    Icons.leaderboard,
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
                  _buildDrawerItem(
                    context,
                    Icons.add,
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
                  _buildDrawerItem(
                    context,
                    Icons.visibility,
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
                  _buildDrawerItem(
                    context,
                    Icons.visibility,
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
                _buildDrawerItem(
                  context,
                  Icons.logout,
                  'Logout',
                  () {
                    authProvider.logout();
                    Navigator.pop(context);
                    // Navigate to login screen
                  },
                ),
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
      leading: Icon(icon, color: const Color(0xFF2196F3)),
      title: Text(title),
      onTap: onTap,
    );
  }
}