import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// Modern custom widgets
import 'package:customer_maxx_crm/widgets/modern_app_bar.dart';
import 'package:customer_maxx_crm/widgets/modern_drawer.dart';
import 'package:customer_maxx_crm/widgets/modern_stats_card.dart';

class ModernAdminDashboardScreen extends StatefulWidget {
  const ModernAdminDashboardScreen({super.key});

  @override
  State<ModernAdminDashboardScreen> createState() => _ModernAdminDashboardScreenState();
}

class _ModernAdminDashboardScreenState extends State<ModernAdminDashboardScreen> {
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    // Get user info from auth bloc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = BlocProvider.of<AuthBloc>(context).state;
        if (authState is Authenticated && authState.user != null) {
          setState(() {
            _userName = authState.user!.name;
            _userEmail = authState.user!.email;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Scaffold(
          appBar: ModernAppBar(
            title: 'Admin Dashboard',
            userName: _userName,
            userEmail: _userEmail,
          ),
          drawer: const ModernDrawer(), // No parameters needed now
          body: RefreshIndicator(
            onRefresh: () async {
              // Refresh data
              await Future.delayed(const Duration(seconds: 1));
            },
            child: CustomScrollView(
              slivers: [
                // Welcome section with profile
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDarkMode
                              ? [const Color(0xFF00BCD4), const Color(0xFF0097A7)]
                              : [const Color(0xFF00BCD4), const Color(0xFF00ACC1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.grey.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back, $_userName!',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Admin - CustomerMaxx CRM',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
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
                      ),
                    ),
                  ),
                ),

                // Stats cards grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 150,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              ModernStatsCard(
                                value: '2',
                                title: 'Projects',
                                icon: Icons.business,
                                color: const Color(0xFF2196F3),
                              ),
                              const SizedBox(width: 16),
                              ModernStatsCard(
                                value: '1500',
                                title: 'Invoices',
                                icon: Icons.receipt,
                                color: const Color(0xFFF44336),
                              ),
                              const SizedBox(width: 16),
                              ModernStatsCard(
                                value: '500',
                                title: 'Payments',
                                icon: Icons.payment,
                                color: const Color(0xFFFF9800),
                              ),
                              const SizedBox(width: 16),
                              ModernStatsCard(
                                value: '1000',
                                title: 'Amount Due',
                                icon: Icons.account_balance_wallet,
                                color: const Color(0xFF4CAF50),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),

                // Charts section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Analytics & Reports',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Bar chart
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode
                                    ? Colors.black.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            primaryYAxis: NumericAxis(),
                            title: ChartTitle(
                              text: 'Total Leads',
                              textStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            series: _getBarSeries(context),
                            tooltipBehavior: TooltipBehavior(enable: true),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Line chart
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode
                                    ? Colors.black.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            primaryYAxis: NumericAxis(),
                            title: ChartTitle(
                              text: 'Weekly Leads Overview',
                              textStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            series: _getLineSeries(context),
                            tooltipBehavior: TooltipBehavior(enable: true),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Pie chart
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode
                                    ? Colors.black.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SfCircularChart(
                            title: ChartTitle(
                              text: 'Lead Status',
                              textStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            legend: Legend(
                              isVisible: true,
                              textStyle: TextStyle(
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            series: _getPieSeries(context),
                            tooltipBehavior: TooltipBehavior(enable: true),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Recent activity section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: isDarkMode
                                    ? Colors.black.withValues(alpha: 0.2)
                                    : Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildActivityItem(
                                Icons.person_add,
                                'New user registered',
                                'John Doe joined as Lead Manager',
                                '2 hours ago',
                                isDarkMode,
                              ),
                              const Divider(height: 1),
                              _buildActivityItem(
                                Icons.leaderboard,
                                'Lead status updated',
                                'Lead #1234 status changed to Demo Attended',
                                '5 hours ago',
                                isDarkMode,
                              ),
                              const Divider(height: 1),
                              _buildActivityItem(
                                Icons.payment,
                                'Payment received',
                                'Payment of \$500 received for Project X',
                                '1 day ago',
                                isDarkMode,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // Show quick actions bottom sheet
              _showQuickActionsBottomSheet(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Quick Actions'),
            backgroundColor: const Color(0xFF00BCD4),
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  // Method to get bar chart data
  List<BarSeries<ChartData, String>> _getBarSeries(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData('Jan', 10),
      ChartData('Feb', 20),
      ChartData('Mar', 15),
      ChartData('Apr', 25),
      ChartData('May', 30),
    ];

    return [
      BarSeries<ChartData, String>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        name: 'Leads',
        color: Theme.of(context).primaryColor,
      ),
    ];
  }

  // Method to get line chart data
  List<LineSeries<ChartData, String>> _getLineSeries(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData('Mon', 5),
      ChartData('Tue', 10),
      ChartData('Wed', 8),
      ChartData('Thu', 12),
      ChartData('Fri', 15),
      ChartData('Sat', 7),
      ChartData('Sun', 9),
    ];

    return [
      LineSeries<ChartData, String>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        name: 'Leads',
        color: Theme.of(context).primaryColor,
      ),
    ];
  }

  // Method to get pie chart data
  List<PieSeries<ChartData, String>> _getPieSeries(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData('New', 12, color: AppThemes.getStatusColor('New')),
      ChartData('Follow Up', 8, color: AppThemes.getStatusColor('Hold')),
      ChartData('Closed', 4, color: AppThemes.getStatusColor('Completed')),
    ];

    return [
      PieSeries<ChartData, String>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        pointColorMapper: (ChartData data, _) => data.color,
        name: 'Leads',
        dataLabelSettings: const DataLabelSettings(isVisible: true),
      ),
    ];
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String description,
    String time,
    bool isDarkMode,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF00BCD4),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.grey[600],
        ),
      ),
      trailing: Text(
        time,
        style: TextStyle(
          color: isDarkMode ? Colors.white54 : Colors.grey[500],
          fontSize: 12,
        ),
      ),
    );
  }

  void _showQuickActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickActionItem(
                    Icons.person_add,
                    'Add User',
                    () {
                      Navigator.pop(context);
                      // Navigate to add user screen
                    },
                  ),
                  _buildQuickActionItem(
                    Icons.leaderboard,
                    'Add Lead',
                    () {
                      Navigator.pop(context);
                      // Navigate to add lead screen
                    },
                  ),
                  _buildQuickActionItem(
                    Icons.analytics,
                    'Reports',
                    () {
                      Navigator.pop(context);
                      // Navigate to reports screen
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionItem(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: const Color(0xFF00BCD4),
              size: 30,
            ),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}

// Data model for charts
class ChartData {
  final String x;
  final double y;
  final Color? color;

  ChartData(this.x, this.y, {this.color});
}