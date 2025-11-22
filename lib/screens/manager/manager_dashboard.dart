import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/manager_dashboard/manager_dashboard_bloc.dart';
import '../../blocs/manager_dashboard/manager_dashboard_event.dart';
import '../../blocs/manager_dashboard/manager_dashboard_state.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_state.dart';
import '../../models/manager_stats.dart';
import '../auth/auth_screen.dart';
import '../notifications/notification_screen.dart';
import '../../utils/theme_utils.dart';
import '../leads/stale_leads_screen.dart';
import 'manager_all_leads_screen.dart';
import '../admin/system_settings_screen.dart';

import 'package:customer_maxx_crm/widgets/notification_badge.dart';

class ModernManagerDashboard extends StatefulWidget {
  const ModernManagerDashboard({super.key});

  @override
  State<ModernManagerDashboard> createState() => _ModernManagerDashboardState();
}

class _ModernManagerDashboardState extends State<ModernManagerDashboard> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    int? managerId;
    if (authState is Authenticated) {
      managerId = int.tryParse(authState.user?.id ?? '');
    }
    context.read<ManagerDashboardBloc>().add(
      LoadManagerStats(managerId: managerId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        return Scaffold(
          backgroundColor: isDarkMode
              ? AppThemes.darkBackground
              : AppThemes.lightBackground,
          appBar: AppBar(
            title: const Text('Manager Dashboard'),
            backgroundColor: isDarkMode
                ? AppThemes.darkCardBackground
                : AppThemes.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              NotificationBadge(isDarkMode: isDarkMode),
              const SizedBox(width: 16),
            ],
          ),
          drawer: _buildDrawer(context, isDarkMode),
          body: BlocBuilder<ManagerDashboardBloc, ManagerDashboardState>(
            builder: (context, state) {
              if (state is ManagerDashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ManagerDashboardLoaded) {
                return _buildDashboard(state.stats);
              } else if (state is ManagerDashboardError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const Center(child: Text('Welcome Manager'));
            },
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDarkMode) {
    return Drawer(
      backgroundColor: isDarkMode
          ? AppThemes.darkBackground
          : AppThemes.lightBackground,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppThemes.darkCardBackground
                  : AppThemes.primaryColor,
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
                    size: 35,
                    color: AppThemes.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Manager Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.dashboard,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            title: Text(
              'Dashboard',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(
              Icons.list_alt,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            title: Text(
              'All Leads',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManagerAllLeadsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.warning_amber_rounded,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            title: Text(
              'Stale Leads',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StaleLeadsScreen(),
                ),
              );
            },
          ),
          // Notification Icon
          NotificationBadge(isDarkMode: isDarkMode),
          ListTile(
            leading: Icon(
              Icons.notifications,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            title: Text(
              'Notifications',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings_system_daydream,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            title: Text(
              'System Settings',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SystemSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) =>
                      const ModernAuthScreen(authMode: AuthMode.login),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(ManagerStats stats) {
    return RefreshIndicator(
      onRefresh: () async {
        final authState = context.read<AuthBloc>().state;
        int? managerId;
        if (authState is Authenticated) {
          managerId = int.tryParse(authState.user?.id ?? '');
        }
        context.read<ManagerDashboardBloc>().add(
          LoadManagerStats(managerId: managerId),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCards(stats),
            const SizedBox(height: 20),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(ManagerStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Total Leads',
          stats.totalLeads.toString(),
          Icons.people,
          Colors.blue,
          [Colors.blue.shade400, Colors.blue.shade700],
        ),
        _buildStatCard(
          'Registered',
          (stats.statusCounts['Registered'] ?? 0).toString(),
          Icons.how_to_reg,
          Colors.green,
          [Colors.green.shade400, Colors.green.shade700],
        ),
        _buildStatCard(
          'Connected',
          (stats.statusCounts['Connected'] ?? 0).toString(),
          Icons.phone_in_talk,
          Colors.teal,
          [Colors.teal.shade400, Colors.teal.shade700],
        ),
        _buildStatCard(
          'Pending',
          (stats.statusCounts['Pending'] ?? 0).toString(),
          Icons.pending_actions,
          Colors.orange,
          [Colors.orange.shade400, Colors.orange.shade700],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    List<Color> gradientColors,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.list_alt, color: Colors.blue),
              ),
              title: const Text('View All Leads'),
              subtitle: const Text('Manage and filter all leads'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManagerAllLeadsScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
