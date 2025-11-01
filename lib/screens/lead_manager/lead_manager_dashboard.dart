import 'dart:developer' as developer;

import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';
import 'package:customer_maxx_crm/widgets/navigation_bar.dart';

import 'package:customer_maxx_crm/widgets/standard_table_view.dart';
import 'package:customer_maxx_crm/widgets/generic_table_view.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:customer_maxx_crm/models/dropdown_data.dart';
import 'package:customer_maxx_crm/utils/api_service_locator.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_state.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_event.dart';

class ModernLeadManagerDashboard extends StatefulWidget {
  final int initialIndex;

  const ModernLeadManagerDashboard({super.key, this.initialIndex = 0});

  @override
  State<ModernLeadManagerDashboard> createState() =>
      _ModernLeadManagerDashboardState();
}

class _ModernLeadManagerDashboardState
    extends State<ModernLeadManagerDashboard> {
  late int _currentNavIndex;
  String _userName = '';
  String _userRole = '';

  // Add Lead Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedLeadManager = '-- Select Lead Manager --';
  String _selectedBASpecialist = '-- Select Specialist --';
  int? _selectedLeadManagerId;
  int? _selectedBASpecialistId;

  List<String> _leadManagers = [
    '-- Select Lead Manager --',
    'Loading...', // Show loading state initially
  ];

  List<String> _baSpecialists = [
    '-- Select Specialist --',
    'Loading...', // Show loading state initially
  ];

  // Add leads data list
  List<Lead> _leadsData = [];

  final List<Widget>? actions = [];
  final bool showDrawer = true;
  DropdownData? dropdownData;
  bool _isLoadingDropdownData = false;
  bool _isLoadingLeadsData = false;
  bool _hasLoadedInitialLeadsData = false;


  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialIndex;
    _loadUserData();
    // We'll fetch dropdown data when needed in the Add Lead view
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    _locationController.dispose();
    super.dispose();
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

  Future<void> _fetchDropdownData() async {
    // For manual refresh (pull-to-refresh or button), always fetch fresh data
    // For automatic loading, prevent duplicate fetches
    final isManualRefresh = !_isLoadingDropdownData && dropdownData != null;
    
    // Don't fetch if already loading (unless it's a manual refresh)
    if (_isLoadingDropdownData && !isManualRefresh) return;
    
    // Set loading flag
    setState(() {
      _isLoadingDropdownData = true;
    });
    
    try {
      // Check if service locator is initialized
      if (!ServiceLocator.isInitialized) return;
      
      final leadService = ServiceLocator.leadService;
      final data = await leadService.getDropdownData();
      
      // Log the fetched data
      developer.log('Fetched dropdown data: ${data.leadManagers.length} lead managers, ${data.baSpecialists.length} BA specialists');
      for (var manager in data.leadManagers) {
        developer.log('Lead Manager: ${manager.id} - ${manager.name}');
      }
      for (var specialist in data.baSpecialists) {
        developer.log('BA Specialist: ${specialist.id} - ${specialist.name}');
      }
      
      // Update state with fetched data
      setState(() {
        dropdownData = data;
        _leadManagers = [
          '-- Select Lead Manager --',
          ...data.leadManagers.map((manager) => manager.name),
        ];
        _baSpecialists = [
          '-- Select Specialist --',
          ...data.baSpecialists.map((specialist) => specialist.name),
        ];
        _isLoadingDropdownData = false;
      });
    } catch (e) {
      // Log the error
      developer.log('Error fetching dropdown data: $e');
      
      // Reset loading flag on error
      setState(() {
        _isLoadingDropdownData = false;
      });
      
      // Show error message if context is still mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dropdown data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // New function to fetch all leads data
  Future<void> _fetchAllLeadsData() async {
    // For manual refresh (pull-to-refresh or button), always fetch fresh data
    // For automatic loading, prevent duplicate fetches
    final isManualRefresh = !_isLoadingLeadsData && _leadsData.isNotEmpty;
    
    // Don't fetch if already loading (unless it's a manual refresh)
    if (_isLoadingLeadsData && !isManualRefresh) return;
    
    // Set loading flag
    setState(() {
      _isLoadingLeadsData = true;
    });
    
    try {
      // Check if service locator is initialized
      if (!ServiceLocator.isInitialized) return;
      
      final leadService = ServiceLocator.leadService;
      final leads = await leadService.getAllLeadsNoPagination();
      
      // Log the fetched leads data
      developer.log('Fetched leads data: ${leads.length} leads');
      for (var lead in leads) {
        developer.log('Lead: ${lead.id} - ${lead.name} (${lead.status})');
      }
      
      // Update state with fetched data
      setState(() {
        _leadsData = leads;
        _isLoadingLeadsData = false;
      });
    } catch (e) {
      // Log the error
      developer.log('Error fetching leads data: $e');
      
      // Reset loading flag on error
      setState(() {
        _isLoadingLeadsData = false;
      });
      
      // Show error message if context is still mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load leads data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: _buildCustomAppBar(context, isDarkMode),
              centerTitle: true,
              backgroundColor: isDarkMode ? Colors.black : Colors.white,
            ),
            // drawer: _buildModernDrawer(context),
            drawer: ModernDrawer(),
            bottomNavigationBar: FloatingNavigationBar(
              currentIndex: _currentNavIndex,
              userRole: _userRole,
              onTap: (index) {
                setState(() {
                  _currentNavIndex = index;
                });
              },
            ),
            // Only show floating action button on the main dashboard (index 0)
            floatingActionButton: _currentNavIndex == 0 ? _buildFloatingActionButton(isDarkMode) : null,
            body: _buildBody(isDarkMode),
          );
      },
    );
  }

  Widget _buildBody(bool isDarkMode) {
    switch (_currentNavIndex) {
      case 0:
        return _buildDashboardView(isDarkMode);
      case 1:
        return _buildAddLeadView(isDarkMode);
      case 2:
        return _buildViewLeadsView(isDarkMode);
      case 3:
        return _buildReportsView(isDarkMode);
      default:
        return _buildDashboardView(isDarkMode);
    }
  }

  Widget _buildCustomAppBar(BuildContext context, bool isDarkMode) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          // Menu/Back Button
          if (showDrawer)
            Builder(
              builder: (BuildContext context) {
                return _buildIconButton(
                  context,
                  Icons.menu_rounded,
                  () => Scaffold.of(context).openDrawer(),
                  isDarkMode,
                );
              },
            ),
          SizedBox(width: width < 360 ? 8 : 12),
      
          // Title
          Expanded(
            child: Text(
              "Lead Manager",
              style: TextStyle(
                fontSize: width < 360 ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      
          // Actions
          if (actions != null) ...actions!,
      
          // Theme Toggle
          _buildIconButton(
            context,
            isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            () => context.read<ThemeBloc>().add(ToggleTheme()),
            isDarkMode,
          ),
      
          SizedBox(width: width < 360 ? 6 : 8),
      
          // Profile Avatar
          _buildProfileAvatar(context, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
    bool isDarkMode,
  ) {
    final width = MediaQuery.of(context).size.width;
    final buttonSize = width < 360 ? 36.0 : 44.0;
    final iconSize = width < 360 ? 18.0 : 20.0;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(width < 360 ? 10 : 12),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
          size: iconSize,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, bool isDarkMode) {
    final width = MediaQuery.of(context).size.width;
    final avatarSize = width < 360 ? 36.0 : 44.0;
    final fontSize = width < 360 ? 14.0 : 16.0;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String userName = 'User';
        if (authState is Authenticated && authState.user != null) {
          userName = authState.user!.name;
        }

        return GestureDetector(
          onTap: () => _showProfileMenu(context),
          child: Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(width < 360 ? 10 : 12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                  blurRadius: width < 360 ? 6 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProfileMenu(BuildContext context) {
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
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded),
              title: const Text('Profile'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(LogoutRequested());
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
              _buildLeadStatsGrid(isDarkMode),
              const SizedBox(height: 24),
              _buildRecentLeads(isDarkMode),
              const SizedBox(height: 24),
              _buildLeadPipeline(isDarkMode),
              const SizedBox(height: 100), // Space for floating nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppThemes.getPrimaryGradient(),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.leaderboard_rounded,
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
                  'Hello, $_userName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lead Manager Dashboard',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have 12 new leads today',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadStatsGrid(bool isDarkMode) {
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
        childAspectRatio: screenWidth < 400
            ? 1.2
            : 1.1, // Reduced aspect ratio for small screens
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final stats = [
          {
            'title': 'Total Leads',
            'value': '1,247',
            'icon': Icons.people_rounded,
            'color': AppThemes.blueAccent,
            'subtitle': '+23 today',
          },
          {
            'title': 'Hot Leads',
            'value': '89',
            'icon': Icons.local_fire_department_rounded,
            'color': AppThemes.redAccent,
            'subtitle': '+5 today',
          },
          {
            'title': 'Converted',
            'value': '156',
            'icon': Icons.check_circle_rounded,
            'color': AppThemes.greenAccent,
            'subtitle': '+12 this week',
          },
          {
            'title': 'Follow-ups',
            'value': '34',
            'icon': Icons.schedule_rounded,
            'color': AppThemes.orangeAccent,
            'subtitle': 'Due today',
          },
        ];
        final stat = stats[index];
        return _buildStatCard(
          stat['title'] as String,
          stat['value'] as String,
          stat['icon'] as IconData,
          stat['color'] as Color,
          stat['subtitle'] as String,
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
    String subtitle,
    bool isDarkMode,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive spacing based on screen size
    final double paddingValue = screenWidth < 400
        ? screenWidth * 0.03
        : screenWidth * 0.04;
    final double smallSpacing = screenWidth < 400
        ? screenWidth * 0.015
        : screenWidth * 0.02;
    final double tinySpacing = screenWidth < 400
        ? screenWidth * 0.005
        : screenWidth * 0.01;

    return Container(
      padding: EdgeInsets.all(paddingValue),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.06),
            blurRadius: screenWidth * 0.01,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row with icon and menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Icon(icon, color: color, size: screenWidth * 0.05),
              ),
              Icon(
                Icons.more_vert_rounded,
                color: isDarkMode ? Colors.white54 : Colors.grey[600],
                size: screenWidth * 0.04,
              ),
            ],
          ),

          SizedBox(height: smallSpacing), // Reduced spacing
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.065,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: tinySpacing), // Reduced spacing
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.032,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? AppThemes.darkSecondaryText
                  : AppThemes.lightSecondaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          SizedBox(height: tinySpacing), // Reduced spacing
          // Subtitle - Made to take minimal space
          Text(
            subtitle,
            style: TextStyle(
              fontSize: screenWidth * 0.028,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLeads(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Leads',
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
                    ? Colors.black.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.06),
                blurRadius: MediaQuery.of(context).size.width * 0.01,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: _getDummyLeads()
                .take(5)
                .map((lead) => _buildLeadListItem(lead, isDarkMode))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLeadListItem(Lead lead, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // CircleAvatar(
          //   radius: 20,
          //   backgroundColor: AppThemes.getStatusColor(
          //     lead.status,
          //   ).withValues(alpha: 0.1),
          //   child: Text(
          //     lead.name[0].toUpperCase(),
          //     style: TextStyle(
          //       color: AppThemes.getStatusColor(lead.status),
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? Colors.white
                        : AppThemes.lightPrimaryText,
                  ),
                ),
                Text(
                  lead.email,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppThemes.getStatusColor(
                lead.status,
              ).withValues(alpha: 0.1),
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
        ],
      ),
    );
  }

  Widget _buildLeadPipeline(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lead Pipeline',
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
                    ? Colors.black.withValues(alpha: 0.15)
                    : Colors.grey.withValues(alpha: 0.06),
                blurRadius: MediaQuery.of(context).size.width * 0.01,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildPipelineStage(
                'New Leads',
                45,
                AppThemes.blueAccent,
                isDarkMode,
              ),
              _buildPipelineStage(
                'Contacted',
                32,
                AppThemes.orangeAccent,
                isDarkMode,
              ),
              _buildPipelineStage(
                'Qualified',
                18,
                AppThemes.purpleAccent,
                isDarkMode,
              ),
              _buildPipelineStage(
                'Proposal Sent',
                12,
                AppThemes.greenAccent,
                isDarkMode,
              ),
              _buildPipelineStage(
                'Closed Won',
                8,
                AppThemes.greenAccent,
                isDarkMode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPipelineStage(
    String stage,
    int count,
    Color color,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              stage,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddLeadView(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < 360 ? 20.0 : 24.0;
    
    // Fetch dropdown data when this view is accessed for the first time
    // Use addPostFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only fetch automatically if data hasn't been loaded yet
      if (dropdownData == null && !_isLoadingDropdownData) {
        _fetchDropdownData();
      }
    });
    
    return RefreshIndicator(
      onRefresh: () async {
        await _fetchDropdownData();
      },
      child: Padding(
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
                        'Add New Lead',
                        style: TextStyle(
                          fontSize: fontSize,
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
                      Icons.refresh,
                      'Refresh Data',
                      () => _fetchDropdownData(),
                      isDarkMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildAddLeadForm(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitLead() async {
    if (_formKey.currentState!.validate()) {
      if (!ServiceLocator.isInitialized) return;
      
      // Check if Lead Manager is selected
      if (_selectedLeadManagerId == null || _selectedLeadManager == '-- Select Lead Manager --') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a Lead Manager'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      try {
        final leadService = ServiceLocator.leadService;
        
        // Create a lead object with the form data using IDs for creation
        final lead = Lead(
          id: 0, // Will be assigned by the server
          name: _nameController.text,
          email: _emailController.text,
          phone: _contactController.text,
          education: _educationController.text,
          experience: _experienceController.text,
          location: _locationController.text,
          status: 'New', // Default status
          feedback: '',
          createdAt: DateTime.now().toIso8601String(),
          ownerName: '', // Not used for creation
          assignedName: '', // Not used for creation
          ownerId: _selectedLeadManagerId,
          assignedTo: _selectedBASpecialistId,
          latestHistory: 'New lead created',
        );
        
        // Log the lead data before submission
        developer.log('Submitting lead: ${lead.toJson()}');
        
        final response = await leadService.createLead(lead);
        
        // Log the response
        developer.log('Lead creation response: $response');
        
        if (context.mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Lead added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Clear form
            _formKey.currentState!.reset();
            _nameController.clear();
            _contactController.clear();
            _emailController.clear();
            _educationController.clear();
            _experienceController.clear();
            _locationController.clear();
            setState(() {
              _selectedLeadManager = '-- Select Lead Manager --';
              _selectedBASpecialist = '-- Select Specialist --';
              _selectedLeadManagerId = null;
              _selectedBASpecialistId = null;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to add lead: ${response['message'] ?? 'Unknown error'}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        // Log the error
        developer.log('Error submitting lead: $e');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add lead: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildAddLeadForm(bool isDarkMode) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(
          //   'Lead Information',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.w600,
          //     color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
          //   ),
          // ),
          // SizedBox(height: spacing + 4),
          _buildFormField(
            'Full Name',
            'Enter lead\'s full name',
            Icons.person_rounded,
            _nameController,
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.04),
          _buildFormField(
            'Email Address',
            'Enter email address',
            Icons.email_rounded,
            _emailController,
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.04),
          _buildFormField(
            'Phone Number',
            'Enter phone number',
            Icons.phone_rounded,
            _contactController,
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.04),
          _buildFormField(
            'Education',
            'Enter education',
            Icons.school_rounded,
            _educationController,
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.04),
          _buildFormField(
            'Experience',
            'Enter experience',
            Icons.work_rounded,
            _experienceController,
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.04),
          _buildFormField(
            'Location',
            'Enter location',
            Icons.location_on_rounded,
            _locationController,
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.04),
          _buildDropdownField('Lead Owner (Lead Manager)', _leadManagers, (value) {
            developer.log('Lead Manager selected: $value');
            setState(() {
              _selectedLeadManager = value ?? '-- Select Lead Manager --';
              // Find and store the ID
              if (dropdownData != null && value != null && value != '-- Select Lead Manager --') {
                final manager = dropdownData!.leadManagers.firstWhere(
                  (m) => m.name == value,
                  orElse: () => dropdownData!.leadManagers.first,
                );
                _selectedLeadManagerId = int.tryParse(manager.id);
              } else {
                _selectedLeadManagerId = null;
              }
            });
          }),
          SizedBox(height: MediaQuery.of(context).size.width * 0.04),
          _buildDropdownField('Assign To (BA Specialist)', _baSpecialists, (value) {
            developer.log('BA Specialist selected: $value');
            setState(() {
              _selectedBASpecialist = value ?? '-- Select Specialist --';
              // Find and store the ID
              if (dropdownData != null && value != null && value != '-- Select Specialist --') {
                final specialist = dropdownData!.baSpecialists.firstWhere(
                  (s) => s.name == value,
                  orElse: () => dropdownData!.baSpecialists.first,
                );
                _selectedBASpecialistId = int.tryParse(specialist.id);
              } else {
                _selectedBASpecialistId = null;
              }
            });
          }),
          SizedBox(height: MediaQuery.of(context).size.width * 0.04 + 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitLead,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.width < 360 ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Add Lead',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 360 ? 15 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String hint, IconData icon, [TextEditingController? controller]) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width < 360 ? 13 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: width < 360 ? 20 : 24),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(width < 360 ? 10 : 12),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: width < 360 ? 12 : 16,
              vertical: width < 360 ? 12 : 16,
            ),
          ),
          // Add basic validation
          validator: (value) {
            if (label == 'Full Name' && (value == null || value.isEmpty)) {
              return 'Please enter a name';
            }
            if (label == 'Email Address' && (value == null || value.isEmpty)) {
              return 'Please enter an email';
            }
            if (label == 'Phone Number' && (value == null || value.isEmpty)) {
              return 'Please enter a phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options, Function(String?) onChanged) {
    final width = MediaQuery.of(context).size.width;
    final isLeadManager = label.contains('Lead Manager');
    final selectedValue = isLeadManager ? _selectedLeadManager : _selectedBASpecialist;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: width < 360 ? 13 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedValue == '-- Select Lead Manager --' || selectedValue == '-- Select Specialist --' 
                 ? null : selectedValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(width < 360 ? 10 : 12),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: width < 360 ? 12 : 16,
              vertical: width < 360 ? 12 : 16,
            ),
          ),
          hint: Text('Select $label'),
          items: options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: onChanged,
          // Add validation
          validator: (value) {
            if (value == null || value.isEmpty || 
                value == '-- Select Lead Manager --' || 
                value == '-- Select Specialist --') {
              return 'Please select a $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildViewLeadsView(bool isDarkMode) {
    return BlocBuilder<LeadsBloc, LeadsState>(
      builder: (context, state) {
        // Load leads data only when needed (first time)
        if (!_hasLoadedInitialLeadsData && state.leads.isEmpty && !state.isLoading && state.error == null) {
          // Use addPostFrameCallback to avoid calling during build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<LeadsBloc>().add(LoadAllLeads());
            setState(() {
              _hasLoadedInitialLeadsData = true;
            });
          });
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            // Reset the flag so we can load data again if needed
            setState(() {
              _hasLoadedInitialLeadsData = false;
            });
            context.read<LeadsBloc>().add(LoadAllLeads());
            // We don't need to wait here as the Bloc will handle the state changes
          },
          child: Builder(
            builder: (context) {
              if (state.isLoading && state.leads.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (state.error != null && state.leads.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.error}'),
                      ElevatedButton(
                        onPressed: () {
                          context.read<LeadsBloc>().add(LoadAllLeads());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              
              final leads = state.leads;
              
              // Log the leads response when we have data (only first time)
              if (leads.isNotEmpty) {
                developer.log('Leads response: ${leads.length} leads loaded');
                // Only log first 3 leads to avoid spam
                for (var i = 0; i < leads.length && i < 3; i++) {
                  final lead = leads[i];
                  developer.log('Lead: ${lead.id} - ${lead.name} (${lead.status})');
                }
              }
              
              return GenericTableView<Lead>(
                title: 'All Leads',
                data: leads,
                filterOptions: const ['Not Connected', 'Follow-up Planned', 'Follow-up Completed', 'Demo Attended', 'Warm Lead', 'Hot Lead', 'Converted'],
                onFilterChanged: (filter) {
                  // Handle filter change if needed
                  developer.log('Filter changed to: $filter');
                },
                columns: [
                  GenericTableColumn(
                    title: 'ID',
                    value: (lead) => lead.id,
                    width: 60,
                  ),
                  // GenericTableColumn(
                  //   title: 'Name',
                  //   value: (lead) => lead.name,
                  //   width: 150,
                  //   builder: (lead) => Row(
                  //     children: [
                  //       // CircleAvatar(
                  //       //   radius: 16,
                  //       //   backgroundColor: AppThemes.getStatusColor(
                  //       //     lead.status,
                  //       //   ).withValues(alpha: 0.1),
                  //       //   child: Text(
                  //       //     lead.name[0].toUpperCase(),
                  //       //     style: TextStyle(
                  //       //       color: AppThemes.getStatusColor(lead.status),
                  //       //       fontWeight: FontWeight.w600,
                  //       //       fontSize: 12,
                  //       //     ),
                  //       //   ),
                  //       // ),
                  //       // const SizedBox(width: 12),
                  //       Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           Text(
                  //             lead.name,
                  //             style: const TextStyle(fontWeight: FontWeight.w500),
                  //             overflow: TextOverflow.ellipsis,
                  //           ),
                  //           Text(
                  //             lead.email,
                  //             style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  //             overflow: TextOverflow.ellipsis,
                  //           ),
                  //         ],
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  GenericTableColumn(title: 'Name', value: (lead) => lead.name, width: 120),
                  GenericTableColumn(title: 'Phone', value: (lead) => lead.phone, width: 130),
                  GenericTableColumn(title: 'Email', value: (lead) => lead.email, width: 150),
                  GenericTableColumn(title: 'Education', value: (lead) => lead.education, width: 120),
                  GenericTableColumn(title: 'Experience', value: (lead) => lead.experience, width: 100),
                  GenericTableColumn(title: 'Location', value: (lead) => lead.location, width: 120),
                  GenericTableColumn(
                    title: 'Status',
                    value: (lead) => lead.status,
                    width: 120,
                    builder: (lead) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppThemes.getStatusColor(
                          lead.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lead.status.isEmpty ? 'N/A' : lead.status,
                        style: TextStyle(
                          color: AppThemes.getStatusColor(lead.status.isEmpty ? 'New' : lead.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GenericTableColumn(title: 'Feedback', value: (lead) => lead.feedback, width: 150),
                  GenericTableColumn(title: 'Created At', value: (lead) => lead.createdAt, width: 150),
                  GenericTableColumn(title: 'Owner', value: (lead) => lead.ownerName, width: 120),
                  GenericTableColumn(title: 'Assigned To', value: (lead) => lead.assignedName, width: 120),
                  GenericTableColumn(title: 'Latest History', value: (lead) => lead.latestHistory, width: 200),
                ],
                onRowTap: (lead) {
                  _showLeadDetails(lead);
                },
                onRowEdit: (lead) {
                  // Handle edit
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildReportsView(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    final width = MediaQuery.of(context).size.width;
    final fontSize = width < 360 ? 20.0 : 24.0;
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
                      'Lead Reports',
                      style: TextStyle(
                        fontSize: fontSize,
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
                    Icons.upload_file_rounded,
                    'CSV file Upload',
                    () => _uploadData(),
                    isDarkMode,
                  ),
                  _buildActionButton(
                    context,
                    Icons.table_chart,
                    'Table Examples',
                    () => Navigator.pushNamed(context, '/table-examples'),
                    isDarkMode,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: screenWidth < 600 ? 2 : 4,
                crossAxisSpacing: screenWidth * 0.03,
                mainAxisSpacing: screenWidth * 0.03,
                childAspectRatio: screenWidth < 400 ? 0.9 : 1.0,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                final reports = [
                  {
                    'title': 'Daily Report',
                    'description': 'Today\'s lead activity',
                    'icon': Icons.today_rounded,
                  },
                  {
                    'title': 'Weekly Report',
                    'description': 'This week\'s performance',
                    'icon': Icons.date_range_rounded,
                  },
                  {
                    'title': 'Monthly Report',
                    'description': 'Monthly lead summary',
                    'icon': Icons.calendar_month_rounded,
                  },
                  {
                    'title': 'Custom Report',
                    'description': 'Generate custom report',
                    'icon': Icons.analytics_rounded,
                  },
                ];
                final report = reports[index];
                return _buildReportCard(
                  report['title'] as String,
                  report['description'] as String,
                  report['icon'] as IconData,
                  isDarkMode,
                );
              },
            ),
            const SizedBox(height: 100), // Space for floating nav
          ],
        ),
      ),
    );
  }

  void _uploadData() {
    // Export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data upload functionality coming soon...')),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
    bool isDarkMode,
  ) {
    final width = MediaQuery.of(context).size.width;
    final iconSize = width < 360 ? 18.0 : 20.0;
    final margin = width < 360 ? 6.0 : 8.0;

    return Container(
      margin: EdgeInsets.only(left: margin),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(width < 360 ? 6 : 8),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDarkMode ? Colors.white70 : Colors.grey[700],
          size: iconSize,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.all(width < 360 ? 8 : 12),
        constraints: BoxConstraints(
          minWidth: width < 360 ? 36 : 44,
          minHeight: width < 360 ? 36 : 44,
        ),
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String description,
    IconData icon,
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
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.06),
            blurRadius: screenWidth * 0.01,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppThemes.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppThemes.primaryColor, size: 20),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? AppThemes.darkSecondaryText
                    : AppThemes.lightSecondaryText,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemes.primaryColor.withValues(alpha: 0.1),
                foregroundColor: AppThemes.primaryColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('Generate', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode) {
    return FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          _currentNavIndex = 1;
        });
      },
      backgroundColor: AppThemes.primaryColor,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add Lead'),
    );
  }

  void _showLeadDetails(Lead lead) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lead Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow('Name', lead.name),
                  _buildDetailRow('Email', lead.email),
                  _buildDetailRow('Phone', lead.phone),
                  _buildDetailRow('Status', lead.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  List<Lead> _getDummyLeads() {
    return [
      Lead(
        id: 1,
        name: 'Alice Johnson',
        email: 'alice@example.com',
        phone: '123-456-7890',
        education: '',
        experience: '',
        location: '',
        status: 'New',
        feedback: '',
        createdAt: DateTime.now().toIso8601String(),
        ownerName: 'achal',
        assignedName: 'Nikita',
        latestHistory: 'Just created',
      ),
      Lead(
        id: 2,
        name: 'Bob Smith',
        email: 'bob@example.com',
        phone: '098-765-4321',
        education: '',
        experience: '',
        location: '',
        status: 'Contacted',
        feedback: '',
        createdAt: DateTime.now().toIso8601String(),
        ownerName: 'achal',
        assignedName: 'Nikita',
        latestHistory: 'Contacted',
      ),
      Lead(
        id: 3,
        name: 'Carol Davis',
        email: 'carol@example.com',
        phone: '555-123-4567',
        education: '',
        experience: '',
        location: '',
        status: 'Qualified',
        feedback: '',
        createdAt: DateTime.now().toIso8601String(),
        ownerName: 'achal',
        assignedName: 'Nikita',
        latestHistory: 'Qualified',
      ),
      Lead(
        id: 4,
        name: 'David Wilson',
        email: 'david@example.com',
        phone: '444-555-6666',
        education: '',
        experience: '',
        location: '',
        status: 'Proposal Sent',
        feedback: '',
        createdAt: DateTime.now().toIso8601String(),
        ownerName: 'achal',
        assignedName: 'Nikita',
        latestHistory: 'Proposal sent',
      ),
      Lead(
        id: 5,
        name: 'Eva Brown',
        email: 'eva@example.com',
        phone: '777-888-9999',
        education: '',
        experience: '',
        location: '',
        status: 'Closed Won',
        feedback: '',
        createdAt: DateTime.now().toIso8601String(),
        ownerName: 'achal',
        assignedName: 'Nikita',
        latestHistory: 'Closed',
      ),
    ];
  }
}
