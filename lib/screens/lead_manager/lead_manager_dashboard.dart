import 'dart:developer' as developer;
import 'dart:developer';

import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';
import 'package:customer_maxx_crm/widgets/navigation_bar.dart';
import 'package:customer_maxx_crm/widgets/generic_table_view.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:customer_maxx_crm/models/dropdown_data.dart';
import 'package:customer_maxx_crm/utils/api_service_locator.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_state.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_event.dart';
import 'package:customer_maxx_crm/services/lead_service.dart';
import 'package:customer_maxx_crm/blocs/lead_manager_dashboard/lead_manager_dashboard_bloc.dart';
import 'package:customer_maxx_crm/models/dashboard_stats.dart';
import 'package:customer_maxx_crm/widgets/notification_badge.dart';
import 'package:shimmer/shimmer.dart';

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
  String _userId = '';
  bool _isLoadingDashboardStats = false;
  bool _hasLoadedInitialDashboardStats = false;
  LeadManagerStats? _leadManagerStats;
  String? _dashboardStatsError;

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

  final List<Widget>? actions = [];
  final bool showDrawer = true;
  DropdownData? dropdownData;
  bool _isLoadingDropdownData = false;
  bool _hasLoadedInitialLeadsData = false;

  final leadService = ServiceLocator.leadService;
  late final LeadManagerDashboardBloc _leadManagerDashboardBloc;

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
          floatingActionButton: _currentNavIndex == 0
              ? _buildFloatingActionButton(isDarkMode)
              : null,
          body: _buildBody(isDarkMode),
        );
      },
    );
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && authState.user != null) {
      setState(() {
        _userName = authState.user!.name;
        _userRole = authState.user!.role;
        _userId = authState.user!.id;
      });
    }
  }

  Future<void> _refreshAllData() async {
    try {
      // Ensure ServiceLocator is initialized
      if (!ServiceLocator.isInitialized) {
        await ServiceLocator.init();
      }

      // Dispatch events to refresh BLoCs
      context.read<LeadsBloc>().add(LoadAllLeads());

      // Force refresh lead manager dashboard data
      await _loadDashboardStats(forceRefresh: true);

      // Show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      log("Error refreshing data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: $e'),
            backgroundColor: AppThemes.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _loadDashboardStats({bool forceRefresh = false}) async {
    // Don't load if already loaded or currently loading, unless force refresh is requested
    if (!forceRefresh &&
        _hasLoadedInitialDashboardStats &&
        _leadManagerStats != null &&
        !_isLoadingDashboardStats) {
      return;
    }

    setState(() {
      _isLoadingDashboardStats = true;
      _dashboardStatsError = null;
      // Reset the stats to show loading shimmer
      if (forceRefresh) {
        _leadManagerStats = null;
      }
    });

    try {
      log('Loading Lead Manager dashboard stats for managerId: $_userId');
      final managerId = int.tryParse(_userId);
      if (managerId != null) {
        final dashboardService = ServiceLocator.dashboardService;
        final stats = await dashboardService.getLeadManagerStats(
          managerId: managerId,
        );
        log(
          'Lead Manager Stats loaded: Total Leads: ${stats.totalLeads}, Status Counts: ${stats.statusCounts.length}',
        );

        setState(() {
          _leadManagerStats = stats;
          _isLoadingDashboardStats = false;
          _hasLoadedInitialDashboardStats = true;
        });
      } else {
        throw Exception('Invalid manager ID: $_userId');
      }
    } catch (e) {
      log('Error loading Lead Manager dashboard stats: $e');
      setState(() {
        _dashboardStatsError = e.toString();
        _isLoadingDashboardStats = false;
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
      developer.log(
        'Fetched dropdown data: ${data.leadManagers.length} lead managers, ${data.baSpecialists.length} BA specialists',
      );
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
      final currentContext = context;
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Failed to load dropdown data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

          // Notification Icon
          NotificationBadge(isDarkMode: isDarkMode),
          SizedBox(width: width < 360 ? 6 : 8),

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
                final currentContext = context;
                if (currentContext.mounted) {
                  currentContext.read<AuthBloc>().add(LogoutRequested());
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardView(bool isDarkMode) {
    // Load dashboard stats if not already loaded
    if (!_hasLoadedInitialDashboardStats &&
        _leadManagerStats == null &&
        !_isLoadingDashboardStats &&
        _dashboardStatsError == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDashboardStats();
      });
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadDashboardStats(forceRefresh: true);
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
              _buildLeadManagerStats(isDarkMode),
              const SizedBox(height: 24),
              _buildRecentLeads(isDarkMode),
              const SizedBox(height: 24),
              _buildStatusCountsChart(isDarkMode),
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
                if (_leadManagerStats != null)
                  Text(
                    'You have ${_leadManagerStats!.statusCounts['Registered'] ?? 0} registered leads',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  )
                else if (_isLoadingDashboardStats)
                  Text(
                    'Loading lead statistics...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    'Welcome to your dashboard',
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
              // Icon(
              //   Icons.more_vert_rounded,
              //   color: isDarkMode ? Colors.white54 : Colors.grey[600],
              //   size: screenWidth * 0.04,
              // ),
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

  Widget _buildLeadManagerStats(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 4;
    final spacing = screenWidth * 0.03;

    // Show shimmer effect while loading
    if (_isLoadingDashboardStats && _leadManagerStats == null) {
      return _buildShimmerLeadManagerStats(isDarkMode);
    }

    // Show error if there was an error loading stats
    if (_dashboardStatsError != null && _leadManagerStats == null) {
      return Center(
        child: Column(
          children: [
            Text('Error: $_dashboardStatsError'),
            ElevatedButton(
              onPressed: () {
                _loadDashboardStats(forceRefresh: true);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show stats grid if we have data
    if (_leadManagerStats != null) {
      return _buildPerformanceStatsGrid(_leadManagerStats!, isDarkMode);
    }

    // Fallback to shimmer if no data and not loading
    return _buildShimmerLeadManagerStats(isDarkMode);
  }

  Widget _buildShimmerLeadManagerStats(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 4;
    final spacing = screenWidth * 0.03;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: screenWidth < 400 ? 1.2 : 1.1,
        ),
        itemCount: 4, // Show 4 shimmer cards
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: 60,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 80,
                  height: 15,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerformanceStatsGrid(LeadManagerStats stats, bool isDarkMode) {
    developer.log(
      'Building PerformanceStatsGrid with ${stats.totalLeads} total leads',
    );
    developer.log('Status counts: ${stats.statusCounts}');

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 4;
    final spacing = screenWidth * 0.03;

    // Use totalLeads from the stats object
    final totalLeads = stats.totalLeads;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: screenWidth < 400 ? 1.2 : 1.1,
      ),
      itemCount: stats.statusCounts.length,
      itemBuilder: (context, index) {
        final statusEntries = stats.statusCounts.entries.toList();
        if (index >= statusEntries.length) return const SizedBox.shrink();

        final entry = statusEntries[index];
        final status = entry.key;
        final count = entry.value;

        // Get appropriate color for status
        final color = _getStatusColor(status);

        return _buildStatCard(
          status,
          count.toString(),
          _getStatusIcon(status),
          color,
          'Total: $totalLeads',
          isDarkMode,
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Not Connected':
        return Icons.phone_disabled_rounded;
      case 'Follow-up Planned':
        return Icons.schedule_rounded;
      case 'Follow-up Completed':
        return Icons.check_circle_outline_rounded;
      case 'Demo Attended':
        return Icons.groups_rounded;
      case 'Warm Lead':
        return Icons.thermostat_rounded;
      case 'Hot Lead':
        return Icons.local_fire_department_rounded;
      case 'Converted':
        return Icons.check_circle_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Not Connected':
        return AppThemes.redAccent;
      case 'Follow-up Planned':
        return AppThemes.orangeAccent;
      case 'Follow-up Completed':
        return AppThemes.blueAccent;
      case 'Demo Attended':
        return AppThemes.purpleAccent;
      case 'Warm Lead':
        return AppThemes
            .orangeAccent; // Changed from yellowAccent which doesn't exist
      case 'Hot Lead':
        return AppThemes.redAccent;
      case 'Converted':
        return AppThemes.greenAccent;
      default:
        return AppThemes.primaryColor;
    }
  }

  Widget _buildStatusCountsChart(bool isDarkMode) {
    if (_leadManagerStats == null) {
      return const SizedBox.shrink();
    }

    final stats = _leadManagerStats!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Distribution',
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
          child: Column(children: _buildStatusBars(stats, isDarkMode)),
        ),
      ],
    );
  }

  List<Widget> _buildStatusBars(LeadManagerStats stats, bool isDarkMode) {
    // Find the maximum count for scaling
    int maxCount = 0;
    stats.statusCounts.forEach((key, value) {
      if (value > maxCount) maxCount = value;
    });

    // If all counts are zero, set maxCount to 1 to avoid division by zero
    if (maxCount == 0) maxCount = 1;

    List<Widget> bars = [];
    stats.statusCounts.forEach((status, count) {
      final color = _getStatusColor(status);
      final percentage = maxCount > 0 ? (count / maxCount) : 0;

      bars.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                status,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              // const SizedBox(width: 12),
              // Expanded(
              //   child: Container(
              //     height: 20,
              //     decoration: BoxDecoration(
              //       color: isDarkMode
              //           ? Colors.grey.withValues(alpha: 0.3)
              //           : Colors.grey.withValues(alpha: 0.1),
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: FractionallySizedBox(
              //       alignment: Alignment.centerLeft,
              //       widthFactor: percentage.toDouble(),
              //       child: Container(
              //         decoration: BoxDecoration(
              //           color: color,
              //           borderRadius: BorderRadius.circular(10),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(width: 40),
              Text(
                count.toString(),
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      );
    });

    return bars;
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
        // Show shimmer while loading and no data
        if (_isLoadingDashboardStats && _leadManagerStats == null)
          _buildShimmerRecentLeads(isDarkMode)
        else if (_leadManagerStats != null)
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
              children: _leadManagerStats!.recentLeads
                  .take(5)
                  .map((lead) => _buildDynamicLeadListItem(lead, isDarkMode))
                  .toList(),
            ),
          )
        else
          // Fallback to dummy data if there's an error or no data
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

  Widget _buildLeadListItem(Map<String, dynamic> lead, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDarkMode
                        ? Colors.white
                        : AppThemes.lightPrimaryText,
                  ),
                ),
                Text(
                  lead['email'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppThemes.darkSecondaryText
                        : AppThemes.lightSecondaryText,
                  ),
                ),
                Text(
                  lead['phone'],
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Current Status',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? AppThemes.darkSecondaryText
                      : AppThemes.lightSecondaryText,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemes.getStatusColor(
                    lead['status'],
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lead['status'],
                  style: TextStyle(
                    color: AppThemes.getStatusColor(lead['status']),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicLeadListItem(RecentLead lead, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
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
                Text(
                  lead.phone,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Current Status',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode
                      ? AppThemes.darkSecondaryText
                      : AppThemes.lightSecondaryText,
                ),
              ),
              const SizedBox(height: 4),
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
        ],
      ),
    );
  }

  Widget _buildShimmerRecentLeads(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
      child: Container(
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
        ),
        child: Column(
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 100,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: 150,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 12,
                          width: 120,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[700]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey[700]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 20,
                        width: 60,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey[700]
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
      if (_selectedLeadManagerId == null ||
          _selectedLeadManager == '-- Select Lead Manager --') {
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

        final currentContext = context;
        if (currentContext.mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(currentContext).showSnackBar(
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
            ScaffoldMessenger.of(currentContext).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to add lead: ${response['message'] ?? 'Unknown error'}',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        // Log the error
        developer.log('Error submitting lead: $e');

        final currentContext = context;
        if (currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
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
          _buildDropdownField('Lead Owner (Lead Manager)', _leadManagers, (
            value,
          ) {
            developer.log('Lead Manager selected: $value');
            setState(() {
              _selectedLeadManager = value ?? '-- Select Lead Manager --';
              // Find and store the ID
              if (dropdownData != null &&
                  value != null &&
                  value != '-- Select Lead Manager --') {
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
          _buildDropdownField('Assign To (BA Specialist)', _baSpecialists, (
            value,
          ) {
            developer.log('BA Specialist selected: $value');
            setState(() {
              _selectedBASpecialist = value ?? '-- Select Specialist --';
              // Find and store the ID
              if (dropdownData != null &&
                  value != null &&
                  value != '-- Select Specialist --') {
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

  Widget _buildFormField(
    String label,
    String hint,
    IconData icon, [
    TextEditingController? controller,
  ]) {
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

  Widget _buildDropdownField(
    String label,
    List<String> options,
    Function(String?) onChanged,
  ) {
    final width = MediaQuery.of(context).size.width;
    final isLeadManager = label.contains('Lead Manager');
    final selectedValue = isLeadManager
        ? _selectedLeadManager
        : _selectedBASpecialist;

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
          initialValue:
              selectedValue == '-- Select Lead Manager --' ||
                  selectedValue == '-- Select Specialist --'
              ? null
              : selectedValue,
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
            if (value == null ||
                value.isEmpty ||
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
        if (!_hasLoadedInitialLeadsData &&
            state.leads.isEmpty &&
            !state.isLoading &&
            state.error == null) {
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
                  developer.log(
                    'Lead: ${lead.id} - ${lead.name} (${lead.status})',
                  );
                }
              }

              return GenericTableView<Lead>(
                title: 'All Leads',
                data: leads,
                filterOptions: const [
                  'Pending',
                  'Connected',
                  'Not Connected',
                  'Demo Interested',
                  'Demo Attended',
                  'Follow-up Planned',
                  'Follow-up Completed',
                  'Converted Warm Lead',
                  'Converted Hot Lead',
                  'Registered',
                ],
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
                  GenericTableColumn(
                    title: 'Name',
                    value: (lead) => lead.name,
                    width: 120,
                  ),
                  GenericTableColumn(
                    title: 'Phone',
                    value: (lead) => lead.phone,
                    width: 130,
                  ),
                  GenericTableColumn(
                    title: 'Email',
                    value: (lead) => lead.email,
                    width: 150,
                  ),
                  GenericTableColumn(
                    title: 'Education',
                    value: (lead) => lead.education,
                    width: 120,
                  ),
                  GenericTableColumn(
                    title: 'Experience',
                    value: (lead) => lead.experience,
                    width: 100,
                  ),
                  GenericTableColumn(
                    title: 'Location',
                    value: (lead) => lead.location,
                    width: 120,
                  ),
                  GenericTableColumn(
                    title: 'Status',
                    value: (lead) => lead.status,
                    width: 120,
                    builder: (lead) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemes.getStatusColor(
                          lead.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lead.status.isEmpty ? 'N/A' : lead.status,
                        style: TextStyle(
                          color: AppThemes.getStatusColor(
                            lead.status.isEmpty ? 'New' : lead.status,
                          ),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GenericTableColumn(
                    title: 'Feedback',
                    value: (lead) => lead.feedback,
                    width: 150,
                  ),
                  GenericTableColumn(
                    title: 'Created At',
                    value: (lead) => lead.createdAt,
                    width: 150,
                  ),
                  GenericTableColumn(
                    title: 'Owner',
                    value: (lead) => lead.ownerName,
                    width: 120,
                  ),
                  GenericTableColumn(
                    title: 'Assigned To',
                    value: (lead) => lead.assignedName,
                    width: 120,
                  ),
                  GenericTableColumn(
                    title: 'Latest History',
                    value: (lead) => lead.latestHistory,
                    width: 200,
                  ),
                ],
                onRowTap: (lead) {
                  _showLeadDetails(lead);
                },
                onRowDelete: (lead) async {
                  // Handle delete
                  await leadService.deleteLead(lead.id);
                  final currentContext = context;
                  if (currentContext.mounted) {
                    currentContext.read<LeadsBloc>().add(LoadAllLeads());
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      const SnackBar(
                        content: Text('Lead deleted successfully'),
                      ),
                    );
                  }
                },
                onRowReassign: (lead) {
                  _showReassignDialog(lead);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showReassignDialog(Lead lead) async {
    // Ensure dropdown data is loaded before showing dialog
    if (dropdownData == null) {
      await _fetchDropdownData();
    }

    if (!mounted) return;

    // Get BA specialists list
    final baSpecialists = dropdownData?.baSpecialists ?? [];

    // Convert the list to int values to find matching selection
    final availableIds = baSpecialists
        .map((ba) => int.tryParse(ba.id))
        .where((id) => id != null)
        .cast<int>()
        .toList();

    // Check if current assignedTo exists in the list, otherwise set to null
    int? selectedBaId =
        (lead.assignedTo != null && availableIds.contains(lead.assignedTo))
        ? lead.assignedTo
        : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Reassign Lead'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reassign ${lead.name} to:'),
                const SizedBox(height: 4),
                if (lead.assignedName.isNotEmpty)
                  Text(
                    'Current: ${lead.assignedName}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 16),
                if (baSpecialists.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Select BA Specialist',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedBaId,
                    items: baSpecialists.map<DropdownMenuItem<int>>((ba) {
                      return DropdownMenuItem<int>(
                        value: int.tryParse(ba.id),
                        child: Text(ba.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedBaId = value;
                      });
                    },
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedBaId == null
                    ? null
                    : () async {
                        Navigator.pop(context);
                        await _reassignLead(lead, selectedBaId!);
                      },
                child: const Text('Reassign'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _reassignLead(Lead lead, int newAssignedTo) async {
    try {
      final leadService = ServiceLocator.leadService;

      // Use the dedicated reassign method which handles notifications
      final response = await leadService.reassignLead(lead.id, newAssignedTo);

      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lead reassigned successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the list
          context.read<LeadsBloc>().add(LoadAllLeads());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reassign: ${response['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
    final currentContext = context;
    if (currentContext.mounted) {
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text('Data upload functionality coming soon...'),
        ),
      );
    }
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
    // Create a stateful widget for the bottom sheet to manage history data
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          _LeadDetailsBottomSheet(lead: lead, leadService: leadService),
    );
  }

  List _getDummyLeads() {
    return [
      {
        "name": "API Test Lead",
        "email": "api_test@example.com",
        "phone": "9876543210",
        "status": "Not Connected",
        "created_at": "2025-10-29 14:31:05",
      },
    ];
  }
}

class _LeadDetailsBottomSheet extends StatefulWidget {
  final Lead lead;
  final LeadService leadService;

  const _LeadDetailsBottomSheet({
    required this.lead,
    required this.leadService,
  });

  @override
  State<_LeadDetailsBottomSheet> createState() =>
      _LeadDetailsBottomSheetState();
}

class _LeadDetailsBottomSheetState extends State<_LeadDetailsBottomSheet> {
  List<LeadHistory> _leadHistory = [];
  bool _isLoadingHistory = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLeadHistory();
  }

  Future<void> _fetchLeadHistory() async {
    try {
      final history = await widget.leadService.getLeadHistory(widget.lead.id);
      // Always update state, regardless of mounted status
      setState(() {
        _leadHistory = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      developer.log('Error fetching lead history: $e');
      // Always update state, regardless of mounted status
      setState(() {
        _isLoadingHistory = false;
        _errorMessage = 'Failed to load lead history: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load lead history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      // margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.5), width: 2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 5,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lead Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow('Name', widget.lead.name),
                    _buildDetailRow('Current Status', widget.lead.status),
                    const SizedBox(height: 20),
                    const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_isLoadingHistory)
                      const Center(child: CircularProgressIndicator())
                    else if (_errorMessage.isNotEmpty)
                      Center(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else if (_leadHistory.isEmpty)
                      const Center(
                        child: Text(
                          'No history available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemCount: _leadHistory.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryItem(_leadHistory[index]);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            child: Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(LeadHistory history) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (history.status != null && history.status!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemes.getStatusColor(
                      history.status!,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    history.status!,
                    style: TextStyle(
                      color: AppThemes.getStatusColor(history.status!),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(
                history.updatedAt,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          if (history.feedback != null && history.feedback!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(history.feedback!, style: const TextStyle(fontSize: 14)),
          ],
          const SizedBox(height: 4),
          Text(
            'Updated by: ${history.updatedBy}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
