import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';
import 'package:customer_maxx_crm/widgets/navigation_bar.dart';
import 'package:customer_maxx_crm/widgets/app_drawer.dart';
import 'package:customer_maxx_crm/widgets/generic_table_view.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:customer_maxx_crm/services/lead_service.dart';
import 'package:customer_maxx_crm/services/profile_service.dart';
import 'package:customer_maxx_crm/utils/api_service_locator.dart';
import 'package:customer_maxx_crm/models/dashboard_stats.dart';
import 'package:customer_maxx_crm/services/dashboard_service.dart';
import 'package:customer_maxx_crm/widgets/notification_badge.dart';
import 'package:shimmer/shimmer.dart';

class ModernBASpecialistDashboard extends StatefulWidget {
  final int initialIndex;

  const ModernBASpecialistDashboard({super.key, this.initialIndex = 0});

  @override
  State<ModernBASpecialistDashboard> createState() =>
      _ModernBASpecialistDashboardState();
}

class _ModernBASpecialistDashboardState
    extends State<ModernBASpecialistDashboard> {
  late int _currentNavIndex;
  String _userName = '';
  String _userRole = '';
  String _userId = '';

  // Profile stats
  int _assignedLeadsCount = 0;
  int _completedLeadsCount = 0;
  int _inProgressLeadsCount = 0;
  int _followUpsCount = 0;

  // Profile loading state
  bool _isLoadingProfile = false;
  String? _profileError;

  late LeadService _leadService;
  late ProfileService _profileService;
  late DashboardService _dashboardService; // Added DashboardService

  // Separate state variables for each section
  List<Lead> _assignedLeads = [];
  List<Lead> _registeredLeads = [];
  bool _isLoadingAssigned = false;
  bool _isLoadingRegistered = false;
  bool _isLoadingProfileData = false;
  bool _isLoadingDashboardStats = false; // Added for dashboard stats loading
  String? _assignedLeadsError;
  String? _registeredLeadsError;
  String? _profileDataError;
  String? _dashboardStatsError; // Added for dashboard stats error

  // Profile data
  Map<String, dynamic>? _profileData;

  // Profile stats
  int _assignedLeadsCountProfile = 0;
  int _completedLeadsCountProfile = 0;
  int _successRateProfile = 0;

  // Dashboard stats
  BAStats? _baStats; // Added BAStats object

  // Flags to track initial data loading for refresh logic
  bool _hasLoadedInitialAssignedData = false;
  bool _hasLoadedInitialRegisteredData = false;
  bool _hasLoadedInitialProfileData = false;
  bool _hasLoadedInitialDashboardStats = false; // Added for dashboard stats
  bool _hasLoadedInitialData = false; // Added for consistent pattern

  final List<Widget>? actions = [];
  final bool showDrawer = true;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialIndex;
    _leadService = ServiceLocator.leadService;
    _profileService = ServiceLocator.profileService;
    _dashboardService =
        ServiceLocator.dashboardService; // Initialize DashboardService
    _loadUserData();

    log('BA Specialist Dashboard initialized with index: $_currentNavIndex');

    // Load data for the initial view only
    if (_currentNavIndex == 1) {
      log('Loading assigned leads on init');
      _loadAssignedLeads();
    } else if (_currentNavIndex == 2) {
      log('Loading registered leads on init');
      _loadRegisteredLeads();
    } else if (_currentNavIndex == 3) {
      log('Loading profile data on init');
      _loadProfileData();
    } else if (_currentNavIndex == 0) {
      log('Loading dashboard stats on init');
      _loadDashboardStats(); // Load dashboard stats for main dashboard
    }
    // For other views, don't preload data - let navigation handle it
    else {
      log('Not preloading any data for index: $_currentNavIndex');
    }
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

  void _handleNavigation(int index) {
    log('Handling navigation to index: $index');
    switch (index) {
      case 0:
        log('Loading dashboard stats');
        _loadDashboardStats();
        break;
      case 1:
        log(
          'Loading assigned leads - Current count: ${_assignedLeads.length}, Loading: $_isLoadingAssigned',
        );
        // The data will be loaded automatically by the build method now
        // We don't need to manually trigger loading here
        break;
      case 2:
        log(
          'Loading registered leads - Current count: ${_registeredLeads.length}, Loading: $_isLoadingRegistered',
        );
        // The data will be loaded automatically by the build method now
        // We don't need to manually trigger loading here
        break;
      case 3:
        log('Loading profile data');
        // Load dashboard stats for profile screen to display statistics
        _loadDashboardStats();
        break;
      default:
        log('No action for index: $index');
        break;
    }
  }

  Future<void> _loadDashboardStats({bool forceRefresh = false}) async {
    // Don't load if already loaded or currently loading, unless force refresh is requested
    if (!forceRefresh &&
        _hasLoadedInitialDashboardStats &&
        _baStats != null &&
        !_isLoadingDashboardStats) {
      return;
    }

    setState(() {
      _isLoadingDashboardStats = true;
      _dashboardStatsError = null;
      // Reset the stats to show loading shimmer
      if (forceRefresh) {
        _baStats = null;
      }
    });

    try {
      log('Loading BA dashboard stats');
      final stats = await _dashboardService.getBAStats();
      log(
        'BA Stats loaded: Total Leads: ${stats.totalLeads}, Registered: ${stats.registeredLeads}, Conversion Rate: ${stats.conversionRate}%',
      );

      setState(() {
        _baStats = stats;
        _isLoadingDashboardStats = false;
        _hasLoadedInitialDashboardStats = true;
      });
    } catch (e) {
      log('Error loading BA dashboard stats: $e');
      setState(() {
        _dashboardStatsError = e.toString();
        _isLoadingDashboardStats = false;
      });
    }
  }

  Future<void> _loadAssignedLeads() async {
    setState(() {
      _isLoadingAssigned = true;
      _assignedLeadsError = null;
    });

    try {
      final leads = await _leadService.getBADashboard();
      log('Assigned leads loaded: ${leads.length} items');
      for (var lead in leads) {
        log(
          'Lead ID: ${lead.id}, Name: ${lead.name}, Email: ${lead.email}, Status: "${lead.status}", Phone: ${lead.phone}',
        );
        log(
          '  Education: ${lead.education}, Experience: ${lead.experience}, Location: ${lead.location}',
        );
        log('  Feedback: ${lead.feedback}, Created: ${lead.createdAt}');
        log('  Owner: ${lead.ownerName}, Assigned: ${lead.assignedName}');
      }
      setState(() {
        _assignedLeads = leads;
        _isLoadingAssigned = false;
      });
      log('Assigned leads state updated. New count: ${_assignedLeads.length}');
    } catch (e) {
      log('Error loading assigned leads: $e');
      setState(() {
        _assignedLeadsError = e.toString();
        _isLoadingAssigned = false;
      });
    }
  }

  Future<void> _loadRegisteredLeads() async {
    setState(() {
      _isLoadingRegistered = true;
      _registeredLeadsError = null;
    });

    try {
      final leads = await _leadService.getRegisteredLeads();
      log('Registered leads loaded: ${leads.length} items');
      for (var lead in leads) {
        log(
          'Lead ID: ${lead.id}, Name: ${lead.name}, Email: ${lead.email}, Status: "${lead.status}", Phone: ${lead.phone}',
        );
        log(
          '  Education: ${lead.education}, Experience: ${lead.experience}, Location: ${lead.location}',
        );
        log(
          '  Discount: ${lead.discount}, Installment1: ${lead.installment1}, Installment2: ${lead.installment2}',
        );
        log('  Owner: ${lead.ownerName}, Assigned: ${lead.assignedName}');
        // Debug calculation
        final totalFees = lead.calculateTotalFees();
        final finalFees = lead.calculateFinalFees();
        log('  Calculated - Total Fees: $totalFees, Final Fees: $finalFees');
      }
      setState(() {
        _registeredLeads = leads;
        _isLoadingRegistered = false;
      });
      log(
        'Registered leads state updated. New count: ${_registeredLeads.length}',
      );
    } catch (e) {
      log('Error loading registered leads: $e');
      setState(() {
        _registeredLeadsError = e.toString();
        _isLoadingRegistered = false;
      });
    }
  }

  Future<void> _loadProfileData() async {
    if (_userId.isEmpty) {
      log('User ID is empty, cannot load profile data');
      return;
    }

    setState(() {
      _isLoadingProfileData = true;
      _profileDataError = null;
    });

    try {
      log('Loading profile data for user ID: $_userId');
      final profileResponse = await _profileService.fetchUserProfile(_userId);

      if (profileResponse['success'] == true) {
        final profileData = profileResponse['data'];
        log('Profile data loaded successfully: $profileData');

        setState(() {
          _profileData = profileData;
          _isLoadingProfileData = false;

          // Update user name from profile data if available
          if (profileData['fullname'] != null) {
            _userName = profileData['fullname'];
          }

          // Set default values for profile stats
          _assignedLeadsCountProfile =
              profileData['assigned_leads'] as int? ?? 0;
          _completedLeadsCountProfile =
              profileData['completed_leads'] as int? ?? 0;
          _successRateProfile = profileData['success_rate'] as int? ?? 0;
        });
      } else {
        throw Exception(
          profileResponse['message'] ?? 'Failed to load profile data',
        );
      }
    } catch (e) {
      log('Error loading profile data: $e');
      setState(() {
        _profileDataError = e.toString();
        _isLoadingProfileData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        log(
          'Building BA Specialist Dashboard - Current Index: $_currentNavIndex',
        );
        log(
          'Assigned Leads Count: ${_assignedLeads.length}, Registered Leads Count: ${_registeredLeads.length}',
        );
        log(
          'Loading States - Assigned: $_isLoadingAssigned, Registered: $_isLoadingRegistered',
        );
        log(
          'Error States - Assigned: $_assignedLeadsError, Registered: $_registeredLeadsError',
        );

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
              log('Bottom nav tapped: $index');
              setState(() {
                _currentNavIndex = index;
              });
              _handleNavigation(index);
            },
          ),
          floatingActionButton: _currentNavIndex == 0
              ? _buildFloatingActionButton(isDarkMode)
              : null,
          body: _buildBody(isDarkMode),
        );
      },
    );
  }

  Widget _buildBody(bool isDarkMode) {
    log('Building body for index: $_currentNavIndex');
    switch (_currentNavIndex) {
      case 0:
        log('Building dashboard view');
        return _buildDashboardView(isDarkMode);
      case 1:
        log('Building assigned leads view');
        return _buildAssignedLeadsView(isDarkMode);
      case 2:
        log('Building registered leads view');
        return _buildRegisteredLeadsView(isDarkMode);
      case 3:
        log('Building profile view');
        return _buildProfileView(isDarkMode);
      default:
        log('Building default dashboard view');
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
              "BA Specialist",
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
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentNavIndex = 3;
                });
                _loadProfileData();
              },
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
    // Load dashboard stats if not already loaded
    if (!_hasLoadedInitialDashboardStats &&
        _baStats == null &&
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
              _buildWorkStatsGrid(isDarkMode),
              const SizedBox(height: 24),
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
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.06),
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
              color: Colors.white.withValues(alpha: 0.2),
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
                  'BA Specialist Dashboard - CustomerMax CRM',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }

  Widget _buildWorkStatsGrid(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 4;
    final spacing = screenWidth * 0.03;

    // Show shimmer effect while loading
    if (_isLoadingDashboardStats && _baStats == null) {
      return _buildShimmerStatsGrid(
        isDarkMode,
        crossAxisCount,
        spacing,
        screenWidth,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: screenWidth < 400 ? 1.05 : 1.1,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        // Use dynamic data from _baStats if available, otherwise use static data
        final stats = [
          {
            'title': 'Assigned Leads',
            'value': _baStats != null ? _baStats!.totalLeads.toString() : '47',
            'icon': Icons.assignment_rounded,
            'color': AppThemes.blueAccent,
            'change': '+3 today',
          },
          {
            'title': 'Registered',
            'value': _baStats != null
                ? _baStats!.registeredLeads.toString()
                : '23',
            'icon': Icons.check_circle_rounded,
            'color': AppThemes.greenAccent,
            'change': 'This week',
          },
          {
            'title': 'Conversion Rate',
            'value': _baStats != null
                ? '${_baStats!.conversionRate.toStringAsFixed(1)}%'
                : '28.6%',
            'icon': Icons.trending_up_rounded,
            'color': AppThemes.purpleAccent,
            'change': 'Overall',
          },
          // {
          //   'title': 'Follow-ups',
          //   'value': '8',
          //   'icon': Icons.schedule_rounded,
          //   'color': AppThemes.orangeAccent,
          //   'change': 'Due today',
          // },
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

  Widget _buildShimmerStatsGrid(
    bool isDarkMode,
    int crossAxisCount,
    double spacing,
    double screenWidth,
  ) {
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
          childAspectRatio: screenWidth < 400 ? 1.05 : 1.1,
        ),
        itemCount: 4,
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
              ],
            ),
          );
        },
      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.03),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
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
                  color: AppThemes.greenAccent.withValues(alpha: 0.1),
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
                _loadRegisteredLeads();
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
                    color: isDarkMode
                        ? Colors.white
                        : AppThemes.lightPrimaryText,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppThemes.darkSecondaryText
                        : AppThemes.lightSecondaryText,
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
                  color: priorityColor.withValues(alpha: 0.1),
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
                  color: isDarkMode
                      ? AppThemes.darkTertiaryText
                      : AppThemes.lightTertiaryText,
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
              color: AppThemes.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppThemes.primaryColor, size: 20),
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
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppThemes.darkSecondaryText
                        : AppThemes.lightSecondaryText,
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
              color: isDarkMode
                  ? AppThemes.darkTertiaryText
                  : AppThemes.lightTertiaryText,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedLeadsView(bool isDarkMode) {
    log('Building assigned leads view with ${_assignedLeads.length} items');
    log('Loading state: $_isLoadingAssigned, Error: $_assignedLeadsError');

    // Load assigned leads data only when needed (first time)
    if (!_hasLoadedInitialData &&
        _assignedLeads.isEmpty &&
        !_isLoadingAssigned &&
        _assignedLeadsError == null) {
      // Use addPostFrameCallback to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAssignedLeads();
        setState(() {
          _hasLoadedInitialData = true;
        });
      });
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Reset the flag so we can load data again if needed
        setState(() {
          _hasLoadedInitialData = false;
        });
        await _loadAssignedLeads();
      },
      child: Builder(
        builder: (context) {
          if (_isLoadingAssigned && _assignedLeads.isEmpty) {
            log('Showing loading indicator for assigned leads');
            return const Center(child: CircularProgressIndicator());
          }

          if (_assignedLeadsError != null && _assignedLeads.isEmpty) {
            log('Showing error for assigned leads: $_assignedLeadsError');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_assignedLeadsError'),
                  ElevatedButton(
                    onPressed: _loadAssignedLeads,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Debug: Print the first few leads
          if (_assignedLeads.isNotEmpty) {
            log(
              'First assigned lead: ${_assignedLeads[0].name}, Status: "${_assignedLeads[0].status}", Email: ${_assignedLeads[0].email}',
            );
          } else {
            log('No assigned leads to display');
          }

          log('Creating GenericTableView with ${_assignedLeads.length} items');

          return GenericTableView<Lead>(
            key: const ValueKey(
              'assigned_leads_table',
            ), // Unique key for this instance
            title: 'Assigned Leads',
            data: _assignedLeads,
            columns: [
              GenericTableColumn<Lead>(
                title: 'ID',
                value: (lead) => lead.id.toString(),
                width: 60,
              ),
              GenericTableColumn<Lead>(
                width: 200,
                title: 'Lead',
                value: (lead) => lead.name,
                builder: (lead) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      lead.email,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GenericTableColumn<Lead>(
                width: 130,
                title: 'Phone',
                value: (lead) => lead.phone,
              ),
              GenericTableColumn<Lead>(
                width: 150,
                title: 'Education',
                value: (lead) => lead.education,
              ),
              GenericTableColumn<Lead>(
                width: 130,
                title: 'Experience',
                value: (lead) => lead.experience,
              ),
              GenericTableColumn<Lead>(
                width: 150,
                title: 'Location',
                value: (lead) => lead.location,
              ),
              GenericTableColumn<Lead>(
                width: 150,
                title: 'Status',
                value: (lead) => lead.status.isEmpty ? 'N/A' : lead.status,
                builder: (lead) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemes.getStatusColor(
                      lead.status.isEmpty ? 'N/A' : lead.status,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    lead.status.isEmpty ? 'N/A' : lead.status,
                    style: TextStyle(
                      color: AppThemes.getStatusColor(
                        lead.status.isEmpty ? 'N/A' : lead.status,
                      ),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              GenericTableColumn<Lead>(
                width: 200,
                title: 'Feedback',
                value: (lead) => lead.feedback,
              ),
              GenericTableColumn<Lead>(
                width: 130,
                title: 'Created At',
                value: (lead) => lead.createdAt,
              ),
              GenericTableColumn<Lead>(
                width: 150,
                title: 'Owner',
                value: (lead) => lead.ownerName,
              ),
              GenericTableColumn<Lead>(
                width: 150,
                title: 'Assigned To',
                value: (lead) => lead.assignedName,
              ),
            ],
            onRowTap: (lead) {
              // _showLeadActions(lead);
              _updateLeadStatusAndFeedback(lead);
            },
            // Enable all interactive features for assigned leads
            showSearch: true,
            showFilter: true,
            showExport: true,
          );
        },
      ),
    );
  }

  Widget _buildRegisteredLeadsView(bool isDarkMode) {
    log('Building registered leads view with ${_registeredLeads.length} items');
    log('Loading state: $_isLoadingRegistered, Error: $_registeredLeadsError');

    // Load registered leads data only when needed (first time)
    if (!_hasLoadedInitialData &&
        _registeredLeads.isEmpty &&
        !_isLoadingRegistered &&
        _registeredLeadsError == null) {
      // Use addPostFrameCallback to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRegisteredLeads();
        setState(() {
          _hasLoadedInitialData = true;
        });
      });
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Reset the flag so we can load data again if needed
        setState(() {
          _hasLoadedInitialData = false;
        });
        await _loadRegisteredLeads();
      },
      child: Builder(
        builder: (context) {
          if (_isLoadingRegistered && _registeredLeads.isEmpty) {
            log('Showing loading indicator for registered leads');
            return const Center(child: CircularProgressIndicator());
          }

          if (_registeredLeadsError != null && _registeredLeads.isEmpty) {
            log('Showing error for registered leads: $_registeredLeadsError');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_registeredLeadsError'),
                  ElevatedButton(
                    onPressed: _loadRegisteredLeads,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Debug: Print the first few leads
          if (_registeredLeads.isNotEmpty) {
            log(
              'First registered lead: ${_registeredLeads[0].name}, Status: "${_registeredLeads[0].status}", Email: ${_registeredLeads[0].email}',
            );
          } else {
            log('No registered leads to display');
          }

          log(
            'Creating GenericTableView with ${_registeredLeads.length} items',
          );

          return GenericTableView<Lead>(
            key: const ValueKey(
              'registered_leads_table',
            ), // Unique key for this instance
            title: 'Registered Leads',
            data: _registeredLeads,
            columns: [
              GenericTableColumn<Lead>(
                title: 'ID',
                value: (lead) => lead.id.toString(),
                width: 60,
              ),
              GenericTableColumn<Lead>(
                width: 200,
                title: 'Lead',
                value: (lead) => lead.name,
                builder: (lead) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      lead.email,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GenericTableColumn<Lead>(
                width: 130,
                title: 'Phone',
                value: (lead) => lead.phone,
              ),
              GenericTableColumn<Lead>(
                width: 150,
                title: 'Education',
                value: (lead) => lead.education,
              ),
              GenericTableColumn<Lead>(
                width: 130,
                title: 'Experience',
                value: (lead) => lead.experience,
              ),
              GenericTableColumn<Lead>(
                width: 150,
                title: 'Location',
                value: (lead) => lead.location,
              ),
              GenericTableColumn<Lead>(
                width: 150,
                title: 'Owner',
                value: (lead) => lead.ownerName,
              ),
              GenericTableColumn<Lead>(
                width: 150,
                title: 'Assigned To',
                value: (lead) => lead.assignedName,
              ),
              GenericTableColumn<Lead>(
                width: 80,
                title: 'Discount',
                value: (lead) => lead.discount?.toString() ?? '0',
              ),
              GenericTableColumn<Lead>(
                width: 110,
                title: 'Installment 1',
                value: (lead) =>
                    lead.installment1?.toStringAsFixed(2) ?? '0.00',
              ),
              GenericTableColumn<Lead>(
                width: 110,
                title: 'Installment 2',
                value: (lead) =>
                    lead.installment2?.toStringAsFixed(2) ?? '0.00',
              ),
              GenericTableColumn<Lead>(
                width: 110,
                title: 'Total Fees',
                value: (lead) => lead.calculateTotalFees().toStringAsFixed(2),
                builder: (lead) => Text(
                  lead.calculateTotalFees().toStringAsFixed(2),
                  style: TextStyle(
                    color: AppThemes.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GenericTableColumn<Lead>(
                width: 110,
                title: 'Final Fees',
                value: (lead) => lead.calculateFinalFees().toStringAsFixed(2),
                builder: (lead) => Text(
                  lead.calculateFinalFees().toStringAsFixed(2),
                  style: TextStyle(
                    color: AppThemes.greenAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            onRowTap: (lead) {
              // _showLeadActions(lead);
              _updateLeadFees(lead);
            },
            // Disable all interactive features for registered leads as requested
            showSearch: false,
            showFilter: false,
            showExport: false,
          );
        },
      ),
    );
  }

  Widget _buildProfileView(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () async {
        await _loadDashboardStats(forceRefresh: true);
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
                        'Profile',
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
                      Icons.edit_rounded,
                      'Edit Profile',
                      () => _showEditProfileDialog(),
                      isDarkMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01,
                  vertical: 8,
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
                  children: [
                    CircleAvatar(
                      radius: screenWidth < 360 ? 40 : 50,
                      backgroundColor: AppThemes.primaryColor.withValues(
                        alpha: 0.1,
                      ),
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
                        color: isDarkMode
                            ? Colors.white
                            : AppThemes.lightPrimaryText,
                      ),
                    ),
                    Text(
                      _userRole,
                      style: TextStyle(
                        fontSize: screenWidth < 360 ? 14 : 16,
                        color: isDarkMode
                            ? AppThemes.darkSecondaryText
                            : AppThemes.lightSecondaryText,
                      ),
                    ),
                    // const SizedBox(height: 30),
                    // _buildProfileStats(isDarkMode),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Add BA Stats section to profile view
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01,
                  vertical: 8,
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
                  children: [
                    Text(
                      'Performance Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? Colors.white
                            : AppThemes.lightPrimaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBAStatsSection(isDarkMode),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.01,
                  vertical: 8,
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? Colors.white
                            : AppThemes.lightPrimaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettingsItem(
                      Icons.notifications_rounded,
                      'Notifications',
                      isDarkMode,
                    ),
                    _buildSettingsItem(
                      Icons.security_rounded,
                      'Privacy & Security',
                      isDarkMode,
                    ),
                    _buildSettingsItem(
                      Icons.help_rounded,
                      'Help & Support',
                      isDarkMode,
                    ),
                    _buildSettingsItem(
                      Icons.logout_rounded,
                      'Logout',
                      isDarkMode,
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 10), // Space for floating nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStats(bool isDarkMode) {
    // Show shimmer effect while loading
    if (_isLoadingDashboardStats && _baStats == null) {
      return _buildShimmerProfileStats(isDarkMode);
    }

    // Use dynamic data from _baStats if available, otherwise use static data
    String leadsValue = _baStats != null
        ? _baStats!.totalLeads.toString()
        : '47';
    String completedValue = _baStats != null
        ? _baStats!.registeredLeads.toString()
        : '23';
    String successRateValue = _baStats != null
        ? '${_baStats!.conversionRate.toStringAsFixed(1)}%'
        : '89%';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatColumn(leadsValue, 'Leads', isDarkMode),
        _buildStatColumn(completedValue, 'Registered', isDarkMode),
        _buildStatColumn(successRateValue, 'Conversion', isDarkMode),
      ],
    );
  }

  Widget _buildShimmerProfileStats(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 50,
                height: 12,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 50,
                height: 12,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 50,
                height: 12,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBAStatsSection(bool isDarkMode) {
    // Show shimmer effect while loading
    if (_isLoadingDashboardStats && _baStats == null) {
      return _buildShimmerBAStatsSection(isDarkMode);
    }

    if (_dashboardStatsError != null) {
      return Center(
        child: Column(
          children: [
            Text('Error loading stats: $_dashboardStatsError'),
            ElevatedButton(
              onPressed: () => _loadDashboardStats(forceRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_baStats == null) {
      // Load stats if not available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDashboardStats();
      });
      return _buildShimmerBAStatsSection(isDarkMode);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              'Total Leads',
              _baStats!.totalLeads.toString(),
              AppThemes.blueAccent,
              isDarkMode,
            ),
            _buildStatItem(
              'Registered',
              _baStats!.registeredLeads.toString(),
              AppThemes.greenAccent,
              isDarkMode,
            ),
            _buildStatItem(
              'Conversion',
              '${_baStats!.conversionRate.toStringAsFixed(1)}%',
              AppThemes.purpleAccent,
              isDarkMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerBAStatsSection(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
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
          Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
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
          Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
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
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    bool isDarkMode,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode
                ? AppThemes.darkSecondaryText
                : AppThemes.lightSecondaryText,
          ),
        ),
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
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
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
            color: isDarkMode
                ? AppThemes.darkSecondaryText
                : AppThemes.lightSecondaryText,
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom > 0
              ? MediaQuery.of(context).viewInsets.bottom
              : 20,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
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
              const Text(
                'Lead Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
              ListTile(
                leading: const Icon(Icons.edit_note_rounded),
                title: const Text('Update Status & Feedback'),
                onTap: () {
                  Navigator.pop(context);
                  _updateLeadStatusAndFeedback(lead);
                },
              ),
              ListTile(
                leading: const Icon(Icons.currency_rupee_rounded),
                title: const Text('Update Fees'),
                onTap: () {
                  Navigator.pop(context);
                  _updateLeadFees(lead);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _updateLeadStatusAndFeedback(Lead lead) {
    final feedbackController = TextEditingController(text: lead.feedback);

    // Available status options
    final statusOptions = [
      'Pending',
      'Connected',
      'Not Connected',
      'Demo Interested',
      'Demo Attended',
      'Follow Up Planned',
      'Follow Up Completed',
      'Converted Warm Lead',
      'Converted Hot Lead',
      'Registered',
    ];

    String selectedStatus = lead.status.isEmpty
        ? statusOptions[0]
        : lead.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 0,
              right: 0,
              top: 20,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
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
                  const Text(
                    'Update Status & Feedback',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Status Dropdown
                        DropdownButtonFormField<String>(
                          initialValue: selectedStatus.isNotEmpty
                              ? selectedStatus
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: statusOptions.map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedStatus = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        // Feedback Text Field
                        TextFormField(
                          controller: feedbackController,
                          decoration: const InputDecoration(
                            labelText: 'Feedback',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                // Update status
                                if (selectedStatus != lead.status) {
                                  final statusResponse = await _leadService
                                      .updateStatus(lead.id, selectedStatus);
                                  if (statusResponse['status'] != 'success') {
                                    throw Exception(
                                      statusResponse['message'] ??
                                          'Failed to update status',
                                    );
                                  }
                                }

                                // Update feedback
                                if (feedbackController.text != lead.feedback) {
                                  final feedbackResponse = await _leadService
                                      .updateFeedback(
                                        lead.id,
                                        feedbackController.text,
                                      );
                                  if (feedbackResponse['status'] != 'success') {
                                    throw Exception(
                                      feedbackResponse['message'] ??
                                          'Failed to update feedback',
                                    );
                                  }
                                }

                                // Show success message
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Status and feedback updated successfully!',
                                      ),
                                    ),
                                  );

                                  // Refresh the current view to show updated data
                                  if (_currentNavIndex == 1) {
                                    _loadAssignedLeads();
                                  } else if (_currentNavIndex == 2) {
                                    _loadRegisteredLeads();
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Update'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _updateLeadFees(Lead lead) {
    final discountController = TextEditingController(
      text: lead.discount?.toString() ?? '',
    );
    final installment1Controller = TextEditingController(
      text: lead.installment1?.toString() ?? '',
    );
    final installment2Controller = TextEditingController(
      text: lead.installment2?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 0,
              right: 0,
              top: 20,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SingleChildScrollView(
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
                  const Text(
                    'Update Fees',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Discount Field
                        TextFormField(
                          controller: discountController,
                          decoration: const InputDecoration(
                            labelText: 'Discount (%)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        // Installment 1 Field
                        TextFormField(
                          controller: installment1Controller,
                          decoration: const InputDecoration(
                            labelText: 'Installment 1',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Installment 2 Field
                        TextFormField(
                          controller: installment2Controller,
                          decoration: const InputDecoration(
                            labelText: 'Installment 2',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                // Parse values
                                final discount =
                                    int.tryParse(discountController.text) ?? 0;
                                final installment1 =
                                    double.tryParse(
                                      installment1Controller.text,
                                    ) ??
                                    0.0;
                                final installment2 =
                                    double.tryParse(
                                      installment2Controller.text,
                                    ) ??
                                    0.0;

                                // Update fees
                                final response = await _leadService.updateFee(
                                  lead.id,
                                  discount,
                                  installment1,
                                  installment2,
                                );

                                if (response['status'] == 'success') {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Fees updated successfully!',
                                        ),
                                      ),
                                    );

                                    // Refresh the current view to show updated data
                                    if (_currentNavIndex == 1) {
                                      _loadAssignedLeads();
                                    } else if (_currentNavIndex == 2) {
                                      _loadRegisteredLeads();
                                    }
                                  }
                                } else {
                                  throw Exception(
                                    response['message'] ??
                                        'Failed to update fees',
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('Update'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: SingleChildScrollView(
          child: Column(
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

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    final roleController = TextEditingController(text: _userRole);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                enabled: false, // Role shouldn't be editable
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // In a real implementation, this would call an API to update the profile
                // For now, we'll just update the UI
                setState(() {
                  _userName = nameController.text;
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating profile: ${e.toString()}'),
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
