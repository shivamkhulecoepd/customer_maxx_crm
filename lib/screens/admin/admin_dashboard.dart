import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_event.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_state.dart';
import 'package:customer_maxx_crm/blocs/users/users_bloc.dart';
import 'package:customer_maxx_crm/blocs/users/users_event.dart';
import 'package:customer_maxx_crm/blocs/users/users_state.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';
import 'package:customer_maxx_crm/widgets/main_layout.dart';
import 'package:customer_maxx_crm/widgets/navigation_bar.dart';

import 'package:customer_maxx_crm/widgets/standard_table_view.dart';
import 'package:customer_maxx_crm/models/user.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ModernAdminDashboard extends StatefulWidget {
  final int initialIndex;

  const ModernAdminDashboard({super.key, this.initialIndex = 0});

  @override
  State<ModernAdminDashboard> createState() => _ModernAdminDashboardState();
}

class _ModernAdminDashboardState extends State<ModernAdminDashboard> {
  late int _currentNavIndex;
  String _userName = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialIndex;
    _loadUserData();
    // Initialize data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<LeadsBloc>().add(LoadAllLeads());
        context.read<UsersBloc>().add(LoadAllUsers());
      }
    });
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && authState.user != null) {
      setState(() {
        _userName = authState.user!.name;
        _userRole = authState.user!.role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LeadsBloc, LeadsState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppThemes.redAccent,
                ),
              );
            }
          },
        ),
        BlocListener<UsersBloc, UsersState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppThemes.redAccent,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDarkMode = themeState.isDarkMode;

          return ModernLayout(
            title: 'Admin Dashboard',
            body: _buildBody(isDarkMode),
            bottomNavigationBar: FloatingNavigationBar(
              currentIndex: _currentNavIndex,
              userRole: _userRole,
              onTap: (index) {
                setState(() {
                  _currentNavIndex = index;
                });
              },
            ),
            floatingActionButton: _buildFloatingActionButton(isDarkMode),
          );
        },
      ),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    // Wrap the content in a container with proper constraints
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: _buildContentView(isDarkMode),
    );
  }

  Widget _buildContentView(bool isDarkMode) {
    switch (_currentNavIndex) {
      case 0:
        return _buildDashboardView(isDarkMode);
      case 1:
        return _buildUsersView(isDarkMode);
      case 2:
        return _buildLeadsView(isDarkMode);
      case 3:
        return _buildAnalyticsView(isDarkMode);
      default:
        return _buildDashboardView(isDarkMode);
    }
  }

  Widget _buildDashboardView(bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<LeadsBloc>().add(LoadAllLeads());
        context.read<UsersBloc>().add(LoadAllUsers());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(isDarkMode),
              const SizedBox(height: 24),
              _buildStatsGrid(isDarkMode),
              const SizedBox(height: 24),
              _buildQuickActions(isDarkMode),
              const SizedBox(height: 24),
              _buildRecentActivity(isDarkMode),
              const SizedBox(height: 100), // Space for floating nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      // margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppThemes.getPrimaryGradient(),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.15)
                : Colors.grey.withOpacity(0.06),
            blurRadius: screenWidth * 0.01,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.06),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, $_userName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admin Dashboard - CustomerMaxx CRM',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Online',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(bool isDarkMode) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, usersState) {
        return BlocBuilder<LeadsBloc, LeadsState>(
          builder: (context, leadsState) {
            final totalUsers = usersState.users.length;
            final totalLeads = leadsState.leads.length;
            final activeLeads = leadsState.leads
                .where(
                  (lead) =>
                      lead.status.toLowerCase() != 'completed' &&
                      lead.status.toLowerCase() != 'rejected',
                )
                .length;
            final completedLeads = leadsState.leads
                .where((lead) => lead.status.toLowerCase() == 'completed')
                .length;
            final conversionRate = totalLeads > 0
                ? ((completedLeads / totalLeads) * 100).toStringAsFixed(1)
                : '0.0';

            final screenWidth = MediaQuery.of(context).size.width;
            final crossAxisCount = screenWidth < 600 ? 2 : 4;
            final spacing = screenWidth * 0.03;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: spacing,
                mainAxisSpacing: spacing,
                childAspectRatio: screenWidth < 400 ? 1.1 : 1.2,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final stats = [
                  {
                    'title': 'Total Users',
                    'value': totalUsers.toString(),
                    'icon': Icons.people_rounded,
                    'color': AppThemes.blueAccent,
                    'change': '+12%',
                  },
                  {
                    'title': 'Active Leads',
                    'value': activeLeads.toString(),
                    'icon': Icons.leaderboard_rounded,
                    'color': AppThemes.greenAccent,
                    'change': '+8%',
                  },
                  {
                    'title': 'Total Leads',
                    'value': totalLeads.toString(),
                    'icon': Icons.assignment_rounded,
                    'color': AppThemes.purpleAccent,
                    'change': '+15%',
                  },
                  {
                    'title': 'Conversion Rate',
                    'value': '$conversionRate%',
                    'icon': Icons.trending_up_rounded,
                    'color': AppThemes.orangeAccent,
                    'change': '+3%',
                  },
                ];
                final stat = stats[index];
                return _buildStatCard(
                  stat['title'] as String,
                  stat['value'] as String,
                  stat['icon'] as IconData,
                  stat['color'] as Color,
                  stat['change'] as String,
                  isDarkMode,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String change,
    bool isDarkMode,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.15)
                : Colors.grey.withOpacity(0.06),
            blurRadius: screenWidth * 0.01,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                child: Icon(icon, color: color, size: screenWidth * 0.06),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.02,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppThemes.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: AppThemes.greenAccent,
                    fontSize: screenWidth * 0.03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.07,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: isDarkMode
                  ? AppThemes.darkSecondaryText
                  : AppThemes.lightSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width * 0.05,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            _buildActionCard('Add User', Icons.person_add_rounded, () {
              setState(() {
                _currentNavIndex = 1;
              });
            }, isDarkMode),
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            _buildActionCard('View Reports', Icons.analytics_rounded, () {
              setState(() {
                _currentNavIndex = 3;
              });
            }, isDarkMode),
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            _buildActionCard('Manage Leads', Icons.leaderboard_rounded, () {
              setState(() {
                _currentNavIndex = 2;
              });
            }, isDarkMode),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(width < 360 ? 16 : 20),
        decoration: BoxDecoration(
          color: isDarkMode ? AppThemes.darkCardBackground : Colors.white,
          borderRadius: BorderRadius.circular(width < 360 ? 12 : 16),
          boxShadow: AppThemes.getCardShadow(isDarkMode),
          border: Border.all(
            color: isDarkMode
                ? AppThemes.darkBorder.withOpacity(0.3)
                : AppThemes.lightBorder.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(width < 360 ? 12 : 16),
              decoration: BoxDecoration(
                color: AppThemes.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(width < 360 ? 10 : 12),
              ),
              child: Icon(
                icon,
                color: AppThemes.primaryColor,
                size: width < 360 ? 24 : 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: width < 360 ? 16 : 18,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isDarkMode ? Colors.white54 : Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.01,
            vertical: 8,
          ),
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(
              MediaQuery.of(context).size.width * 0.04,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.15)
                    : Colors.grey.withOpacity(0.06),
                blurRadius: MediaQuery.of(context).size.width * 0.01,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                Icons.person_add_rounded,
                'New user registered',
                'John Doe joined as Lead Manager',
                '2 hours ago',
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                Icons.leaderboard_rounded,
                'Lead status updated',
                'Lead #1234 status changed to Demo Attended',
                '5 hours ago',
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                Icons.payment_rounded,
                'Payment received',
                'Payment of \$500 received for Project X',
                '1 day ago',
                isDarkMode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String description,
    String time,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            decoration: BoxDecoration(
              color: AppThemes.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.02,
              ),
            ),
            child: Icon(
              icon,
              color: AppThemes.primaryColor,
              size: MediaQuery.of(context).size.width * 0.05,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? Colors.white
                        : AppThemes.lightPrimaryText,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppThemes.darkSecondaryText
                        : AppThemes.lightSecondaryText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode
                  ? AppThemes.darkTertiaryText
                  : AppThemes.lightTertiaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersView(bool isDarkMode) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, usersState) {
        return ModernTableView<User>(
          title: 'User Management',
          data: usersState.users,
          isLoading: usersState.isLoading,
          columns: [
            TableColumn(
              title: 'Name',
              value: (user) => user.name,
              builder: (user) => Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppThemes.primaryColor.withOpacity(0.1),
                    child: Text(
                      user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppThemes.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(user.name),
                ],
              ),
            ),
            TableColumn(title: 'Email', value: (user) => user.email),
            TableColumn(
              title: 'Role',
              value: (user) => user.role,
              builder: (user) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemes.getStatusColor(user.role).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  user.role,
                  style: TextStyle(
                    color: AppThemes.getStatusColor(user.role),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            TableColumn(
              title: 'Status',
              value: (user) => 'Active',
              builder: (user) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemes.greenAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Active',
                  style: TextStyle(
                    color: AppThemes.greenAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          onRowEdit: (user) {
            // Handle edit
          },
          onRowDelete: (user) {
            context.read<UsersBloc>().add(DeleteUser(user.id));
          },
        );
      },
    );
  }

  Widget _buildLeadsView(bool isDarkMode) {
    return BlocBuilder<LeadsBloc, LeadsState>(
      builder: (context, leadsState) {
        return ModernTableView<Lead>(
          title: 'Leads Management',
          data: leadsState.leads,
          isLoading: leadsState.isLoading,
          columns: [
            TableColumn(title: 'Lead ID', value: (lead) => lead.id),
            TableColumn(title: 'Name', value: (lead) => lead.name),
            TableColumn(title: 'Email', value: (lead) => lead.email),
            TableColumn(
              title: 'Status',
              value: (lead) => lead.status,
              builder: (lead) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemes.getStatusColor(lead.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lead.status,
                  style: TextStyle(
                    color: AppThemes.getStatusColor(lead.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          onRowTap: (lead) {
            // Handle row tap
          },
          onRowDelete: (lead) {
            context.read<LeadsBloc>().add(DeleteLead(lead.id));
          },
        );
      },
    );
  }

  Widget _buildAnalyticsView(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : const Color(0xFFF8FAFC),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Analytics & Reports",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? Colors.white
                            : const Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildActionButton(
                    context,
                    Icons.download_rounded,
                    'Export',
                    () => (),
                    isDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildChartCard('Monthly Leads', _buildBarChart(), isDarkMode),
            SizedBox(height: screenWidth * 0.04),
            _buildChartCard(
              'Lead Status Distribution',
              _buildPieChart(),
              isDarkMode,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDarkMode ? Colors.white70 : Colors.grey[700],
          size: 20,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart, bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: 8),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.15)
                : Colors.grey.withOpacity(0.06),
            blurRadius: screenWidth * 0.01,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: chart,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(),
      series: <CartesianSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: [
            ChartData('Jan', 35),
            ChartData('Feb', 28),
            ChartData('Mar', 34),
            ChartData('Apr', 32),
            ChartData('May', 40),
          ],
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          color: AppThemes.primaryColor,
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return SfCircularChart(
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: [
            ChartData('New', 30),
            ChartData('In Progress', 25),
            ChartData('Completed', 45),
          ],
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode) {
    return FloatingActionButton.extended(
      onPressed: () {
        _showQuickActionsBottomSheet();
      },
      backgroundColor: AppThemes.primaryColor,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Quick Add'),
    );
  }

  void _showQuickActionsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_add_rounded),
              title: const Text('Add User'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to add user screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard_rounded),
              title: const Text('Add Lead'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to add lead screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_rounded),
              title: const Text('Generate Report'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}
