import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';
import 'package:customer_maxx_crm/widgets/modern_layout.dart';
import 'package:customer_maxx_crm/widgets/modern_navigation_bar.dart';

import 'package:customer_maxx_crm/widgets/modern_table_view.dart';
import 'package:customer_maxx_crm/models/lead.dart';

class ModernBASpecialistDashboard extends StatefulWidget {
  final int initialIndex;

  const ModernBASpecialistDashboard({super.key, this.initialIndex = 0});

  @override
  State<ModernBASpecialistDashboard> createState() => _ModernBASpecialistDashboardState();
}

class _ModernBASpecialistDashboardState extends State<ModernBASpecialistDashboard> {
  late int _currentNavIndex;
  String _userName = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialIndex;
    _loadUserData();
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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        
        return ModernLayout(
          title: 'BA Specialist',
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
    );
  }

  Widget _buildBody(bool isDarkMode) {
    switch (_currentNavIndex) {
      case 0:
        return _buildDashboardView(isDarkMode);
      case 1:
        return _buildRegisteredLeadsView(isDarkMode);
      case 2:
        return _buildTasksView(isDarkMode);
      case 3:
        return _buildProfileView(isDarkMode);
      default:
        return _buildDashboardView(isDarkMode);
    }
  }

  Widget _buildDashboardView(bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: () async {
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
              _buildWorkStatsGrid(isDarkMode),
              const SizedBox(height: 24),
              _buildTodaysTasks(isDarkMode),
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
      decoration: BoxDecoration(
        gradient: AppThemes.getPrimaryGradient(),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.15) : Colors.grey.withOpacity(0.06),
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
                Icons.business_center_rounded,
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
                    'BA Specialist Dashboard - CustomerMaxx CRM',
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

  Widget _buildWorkStatsGrid(bool isDarkMode) {
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
            'title': 'Assigned Leads',
            'value': '47',
            'icon': Icons.assignment_rounded,
            'color': AppThemes.blueAccent,
            'change': '+3 today',
          },
          {
            'title': 'Completed',
            'value': '23',
            'icon': Icons.check_circle_rounded,
            'color': AppThemes.greenAccent,
            'change': 'This week',
          },
          {
            'title': 'In Progress',
            'value': '12',
            'icon': Icons.hourglass_empty_rounded,
            'color': AppThemes.orangeAccent,
            'change': 'Active now',
          },
          {
            'title': 'Follow-ups',
            'value': '8',
            'icon': Icons.schedule_rounded,
            'color': AppThemes.purpleAccent,
            'change': 'Due today',
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
            color: isDarkMode ? Colors.black.withOpacity(0.15) : Colors.grey.withOpacity(0.06),
            blurRadius: screenWidth * 0.01,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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

  Widget _buildTodaysTasks(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentNavIndex = 2;
                });
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01, vertical: 8),
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.04),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black.withOpacity(0.15) : Colors.grey.withOpacity(0.06),
                blurRadius: MediaQuery.of(context).size.width * 0.01,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTaskItem(
                'Follow up with Alice Johnson',
                'Call regarding proposal discussion',
                'High',
                '10:00 AM',
                false,
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildTaskItem(
                'Demo preparation for Bob Smith',
                'Prepare product demo materials',
                'Medium',
                '2:00 PM',
                false,
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildTaskItem(
                'Send proposal to Carol Davis',
                'Email customized proposal document',
                'High',
                '4:00 PM',
                true,
                isDarkMode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(
    String title,
    String description,
    String priority,
    String time,
    bool isCompleted,
    bool isDarkMode,
  ) {
    final priorityColor = priority == 'High' 
        ? AppThemes.redAccent 
        : priority == 'Medium' 
            ? AppThemes.orangeAccent 
            : AppThemes.greenAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: (value) {},
            activeColor: AppThemes.greenAccent,
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
                    color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? AppThemes.darkSecondaryText : AppThemes.lightSecondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? AppThemes.darkTertiaryText : AppThemes.lightTertiaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
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
          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01, vertical: 8),
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.04),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black.withOpacity(0.15) : Colors.grey.withOpacity(0.06),
                blurRadius: MediaQuery.of(context).size.width * 0.01,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                Icons.call_rounded,
                'Called Alice Johnson',
                'Discussed project requirements',
                '30 min ago',
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                Icons.email_rounded,
                'Sent proposal to Bob Smith',
                'Customized proposal for web development',
                '2 hours ago',
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                Icons.event_rounded,
                'Scheduled demo with Carol Davis',
                'Product demo scheduled for tomorrow',
                '4 hours ago',
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppThemes.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppThemes.primaryColor,
              size: 20,
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
                    color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? AppThemes.darkSecondaryText : AppThemes.lightSecondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? AppThemes.darkTertiaryText : AppThemes.lightTertiaryText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredLeadsView(bool isDarkMode) {
    final leads = _getAssignedLeads();
    
    return ModernTableView<Lead>(
      title: 'Assigned Leads',
      data: leads,
      columns: [
        TableColumn(
          title: 'Lead',
          value: (lead) => lead.name,
          builder: (lead) => Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppThemes.getStatusColor(lead.status).withOpacity(0.1),
                child: Text(
                  lead.name[0].toUpperCase(),
                  style: TextStyle(
                    color: AppThemes.getStatusColor(lead.status),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      lead.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TableColumn(
          title: 'Phone',
          value: (lead) => lead.phone,
        ),
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
        TableColumn(
          title: 'Priority',
          value: (lead) => 'High', // Mock priority
          builder: (lead) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppThemes.redAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'High',
              style: TextStyle(
                color: AppThemes.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
      onRowTap: (lead) {
        _showLeadActions(lead);
      },
    );
  }

  Widget _buildTasksView(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : const Color(0xFFF8FAFC),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'All Tasks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildActionButton(
                  context,
                  Icons.add_task_rounded,
                  'Add Task',
                  () => _showAddTaskDialog(),
                  isDarkMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Column(
              children: [
                _buildTaskFilter(isDarkMode),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildTaskItem(
                        'Follow up with Alice Johnson',
                        'Call regarding proposal discussion',
                        'High',
                        '10:00 AM',
                        false,
                        isDarkMode,
                      ),
                      _buildTaskItem(
                        'Demo preparation for Bob Smith',
                        'Prepare product demo materials',
                        'Medium',
                        '2:00 PM',
                        false,
                        isDarkMode,
                      ),
                      _buildTaskItem(
                        'Send proposal to Carol Davis',
                        'Email customized proposal document',
                        'High',
                        '4:00 PM',
                        true,
                        isDarkMode,
                      ),
                      _buildTaskItem(
                        'Client meeting with David Wilson',
                        'Discuss project timeline and requirements',
                        'Medium',
                        'Tomorrow 9:00 AM',
                        false,
                        isDarkMode,
                      ),
                      _buildTaskItem(
                        'Follow up with Alice Johnson',
                        'Call regarding proposal discussion',
                        'High',
                        '10:00 AM',
                        false,
                        isDarkMode,
                      ),
                      _buildTaskItem(
                        'Demo preparation for Bob Smith',
                        'Prepare product demo materials',
                        'Medium',
                        '2:00 PM',
                        false,
                        isDarkMode,
                      ),
                      _buildTaskItem(
                        'Send proposal to Carol Davis',
                        'Email customized proposal document',
                        'High',
                        '4:00 PM',
                        true,
                        isDarkMode,
                      ),
                      _buildTaskItem(
                        'Client meeting with David Wilson',
                        'Discuss project timeline and requirements',
                        'Medium',
                        'Tomorrow 9:00 AM',
                        false,
                        isDarkMode,
                      ),
                      _buildTaskItem(
                        'Follow up with Alice Johnson',
                        'Call regarding proposal discussion',
                        'High',
                        '10:00 AM',
                        false,
                        isDarkMode,
                      ),
                      _buildTaskItem(
                        'Demo preparation for Bob Smith',
                        'Prepare product demo materials',
                        'Medium',
                        '2:00 PM',
                        false,
                        isDarkMode,
                      ),
                      _buildTaskItem(
                        'Send proposal to Carol Davis',
                        'Email customized proposal document',
                        'High',
                        '4:00 PM',
                        true,
                        isDarkMode,
                      ),
                      _buildTaskItem(
                        'Client meeting with David Wilson',
                        'Discuss project timeline and requirements',
                        'Medium',
                        'Tomorrow 9:00 AM',
                        false,
                        isDarkMode,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskFilter(bool isDarkMode) {
    final width = MediaQuery.of(context).size.width;
    final padding = width < 360 ? 12.0 : 16.0;
    
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: Icon(Icons.search_rounded, size: width < 360 ? 20 : 24),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width < 360 ? 10 : 12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDarkMode 
                  ? AppThemes.darkSurfaceBackground
                  : AppThemes.lightSurfaceBackground,
              contentPadding: EdgeInsets.symmetric(
                horizontal: width < 360 ? 12 : 16,
                vertical: width < 360 ? 12 : 16,
              ),
            ),
          ),
        ),
        SizedBox(width: width < 360 ? 8 : 12),
        Container(
          decoration: BoxDecoration(
            color: AppThemes.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(width < 360 ? 10 : 12),
          ),
          child: IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: AppThemes.primaryColor,
              size: width < 360 ? 20 : 24,
            ),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildProfileView(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.black : const Color(0xFFF8FAFC),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildActionButton(
                    context,
                    Icons.edit_rounded,
                    'Edit Profile',
                    () => (),
                    isDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: 8),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black.withOpacity(0.15) : Colors.grey.withOpacity(0.06),
                    blurRadius: screenWidth * 0.01,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: screenWidth < 360 ? 40 : 50,
                    backgroundColor: AppThemes.primaryColor.withOpacity(0.1),
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        color: AppThemes.primaryColor,
                        fontSize: screenWidth < 360 ? 28 : 36,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 20 : 24,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
                    ),
                  ),
                  Text(
                    _userRole,
                    style: TextStyle(
                      fontSize: screenWidth < 360 ? 14 : 16,
                      color: isDarkMode ? AppThemes.darkSecondaryText : AppThemes.lightSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildProfileStats(isDarkMode),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: 8),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.black.withOpacity(0.15) : Colors.grey.withOpacity(0.06),
                    blurRadius: screenWidth * 0.01,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsItem(Icons.notifications_rounded, 'Notifications', isDarkMode),
                  _buildSettingsItem(Icons.security_rounded, 'Privacy & Security', isDarkMode),
                  _buildSettingsItem(Icons.help_rounded, 'Help & Support', isDarkMode),
                  _buildSettingsItem(Icons.logout_rounded, 'Logout', isDarkMode),
                ],
              ),
            ),
            const SizedBox(height: 100), // Space for floating nav
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStats(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn('47', 'Leads', isDarkMode),
        _buildStatColumn('23', 'Completed', isDarkMode),
        _buildStatColumn('89%', 'Success Rate', isDarkMode),
      ],
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

  Widget _buildStatColumn(String value, String label, bool isDarkMode) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? AppThemes.darkSecondaryText : AppThemes.lightSecondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, bool isDarkMode) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDarkMode ? Colors.white70 : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: isDarkMode ? Colors.white54 : Colors.grey[600],
      ),
      onTap: () {},
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode) {
    return FloatingActionButton.extended(
      onPressed: () {
        _showAddTaskDialog();
      },
      backgroundColor: AppThemes.primaryColor,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_task_rounded),
      label: const Text('Add Task'),
    );
  }

  void _showLeadActions(Lead lead) {
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
              'Lead Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.call_rounded),
              title: const Text('Call Lead'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.email_rounded),
              title: const Text('Send Email'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.event_rounded),
              title: const Text('Schedule Meeting'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.note_add_rounded),
              title: const Text('Add Note'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task added successfully!')),
              );
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  List<Lead> _getAssignedLeads() {
    return [
      Lead(id: '1', date: DateTime.now(), name: 'Alice Johnson', email: 'alice@example.com', phone: '123-456-7890', leadManager: 'achal', status: 'New', feedback: '', education: '', experience: '', location: '', orderBy: '', assignedBy: 'Nikita', discount: '', baSpecialist: 'Nikita'),
      Lead(id: '2', date: DateTime.now(), name: 'Bob Smith', email: 'bob@example.com', phone: '098-765-4321', leadManager: 'achal', status: 'Contacted', feedback: '', education: '', experience: '', location: '', orderBy: '', assignedBy: 'Nikita', discount: '', baSpecialist: 'Nikita'),
      Lead(id: '3', date: DateTime.now(), name: 'Carol Davis', email: 'carol@example.com', phone: '555-123-4567', leadManager: 'achal', status: 'Qualified', feedback: '', education: '', experience: '', location: '', orderBy: '', assignedBy: 'Nikita', discount: '', baSpecialist: 'Nikita'),
      Lead(id: '4', date: DateTime.now(), name: 'David Wilson', email: 'david@example.com', phone: '444-555-6666', leadManager: 'achal', status: 'Proposal Sent', feedback: '', education: '', experience: '', location: '', orderBy: '', assignedBy: 'Nikita', discount: '', baSpecialist: 'Nikita'),
    ];
  }
}