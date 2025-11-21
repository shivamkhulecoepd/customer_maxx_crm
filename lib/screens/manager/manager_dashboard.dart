import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/manager_dashboard/manager_dashboard_bloc.dart';
import '../../blocs/manager_dashboard/manager_dashboard_event.dart';
import '../../blocs/manager_dashboard/manager_dashboard_state.dart';
import '../../models/manager_stats.dart';
import '../notifications/notification_screen.dart';
import '../leads/stale_leads_screen.dart';

class ModernManagerDashboard extends StatefulWidget {
  const ModernManagerDashboard({Key? key}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Manager Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: const Text('Stale Leads'),
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
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
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
          ],
        ),
      ),
      body: BlocBuilder<ManagerDashboardBloc, ManagerDashboardState>(
        builder: (context, state) {
          if (state is ManagerDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ManagerDashboardError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ManagerDashboardLoaded) {
            return _buildDashboard(state.stats);
          }
          return const Center(child: Text('Welcome Manager'));
        },
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
            _buildStatCard(
              'Total Leads',
              stats.totalLeads.toString(),
              Icons.people,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Assigned',
                    stats.assignedLeads.toString(),
                    Icons.assignment_ind,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Unassigned',
                    stats.unassignedLeads.toString(),
                    Icons.assignment_late,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Registered',
                    stats.registeredLeads.toString(),
                    Icons.how_to_reg,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Not Connected',
                    stats.notConnectedLeads.toString(),
                    Icons.phone_missed,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              'Team Members',
              stats.totalTeamMembers.toString(),
              Icons.group,
              Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
