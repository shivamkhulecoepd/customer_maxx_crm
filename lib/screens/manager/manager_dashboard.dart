import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';
import 'package:customer_maxx_crm/widgets/navigation_bar.dart';
import 'package:customer_maxx_crm/models/manager_stats.dart';
import 'package:customer_maxx_crm/blocs/manager_dashboard/manager_dashboard_bloc.dart';
import 'package:customer_maxx_crm/blocs/manager_dashboard/manager_dashboard_event.dart';
import 'package:customer_maxx_crm/blocs/manager_dashboard/manager_dashboard_state.dart';
import 'package:customer_maxx_crm/widgets/notification_badge.dart';
import 'package:customer_maxx_crm/screens/manager/manager_all_leads_widget.dart';
import 'package:customer_maxx_crm/screens/manager/stale_leads_widget.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_event.dart';

import '../auth/auth_screen.dart';
import '../notifications/notification_screen.dart';


class ModernManagerDashboard extends StatefulWidget {
  const ModernManagerDashboard({super.key});

  @override
  State<ModernManagerDashboard> createState() => _ModernManagerDashboardState();
}

class _ModernManagerDashboardState extends State<ModernManagerDashboard> {
  String _userName = '';
  String _userRole = '';
  int _currentIndex = 0;
  bool _hasLoadedInitialData = false;

  final List<Widget>? actions = [];
  final bool showDrawer = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Load initial data
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load manager stats on initialization
    final authState = context.read<AuthBloc>().state;
    int? managerId;
    if (authState is Authenticated) {
      managerId = int.tryParse(authState.user?.id ?? '');
    }
    // Use addPostFrameCallback to avoid calling during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagerDashboardBloc>().add(
        LoadManagerStats(managerId: managerId),
      );
      // Also load leads data upfront so it's available immediately when navigating to All Leads screen
      context.read<LeadsBloc>().add(LoadAllLeads());
      setState(() {
        _hasLoadedInitialData = true;
      });
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
          drawer: ModernDrawer(),
          bottomNavigationBar: FloatingNavigationBar(
            currentIndex: _currentIndex,
            userRole: 'manager', // Force manager role for navigation items
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          body: _buildContentView(isDarkMode),
        );
      },
    );
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
              "Manager Dashboard",
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

  Widget _buildContentView(bool isDarkMode) {
    switch (_currentIndex) {
      case 0: // Main Dashboard
        return BlocBuilder<ManagerDashboardBloc, ManagerDashboardState>(
          builder: (context, state) {
            if (state is ManagerDashboardLoading) {
              return _buildDashboardShimmer(isDarkMode);
            } else if (state is ManagerDashboardLoaded) {
              return _buildDashboardView(state.stats, isDarkMode);
            } else if (state is ManagerDashboardError) {
              return _buildErrorView(state.message, isDarkMode);
            }
            return _buildDashboardShimmer(isDarkMode);
          },
        );
      case 1: // All Leads
        return const ManagerAllLeadsWidget();
      case 2: // Stale Leads
        return const StaleLeadsWidget();
      default:
        return BlocBuilder<ManagerDashboardBloc, ManagerDashboardState>(
          builder: (context, state) {
            if (state is ManagerDashboardLoading) {
              return _buildDashboardShimmer(isDarkMode);
            } else if (state is ManagerDashboardLoaded) {
              return _buildDashboardView(state.stats, isDarkMode);
            } else if (state is ManagerDashboardError) {
              return _buildErrorView(state.message, isDarkMode);
            }
            return _buildDashboardShimmer(isDarkMode);
          },
        );
    }
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
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) =>
                        const ModernAuthScreen(authMode: AuthMode.login),
                  ),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardView(ManagerStats stats, bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: () async {
        // Reset loading flags to ensure fresh data
        setState(() {
          _hasLoadedInitialData = false;
        });

        // Load fresh data
        final authState = context.read<AuthBloc>().state;
        int? managerId;
        if (authState is Authenticated) {
          managerId = int.tryParse(authState.user?.id ?? '');
        }
        context.read<ManagerDashboardBloc>().add(
          LoadManagerStats(managerId: managerId),
        );

        // Wait for data to load
        await Future.delayed(const Duration(milliseconds: 500));
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
              _buildStatsGrid(stats, isDarkMode),
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
              Icons.supervisor_account_rounded,
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
                  'Manager Dashboard - CustomerMax CRM',
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

  Widget _buildStatsGrid(ManagerStats stats, bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: screenWidth * 0.03,
        crossAxisSpacing: screenWidth * 0.03,
        childAspectRatio: screenWidth < 400 ? 1.1 : 1.2,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final statData = [
          {
            'title': 'Total Leads',
            'value': stats.totalLeads.toString(),
            'icon': Icons.leaderboard_rounded,
            'color': AppThemes.blueAccent,
            'change': '+12%',
          },
          {
            'title': 'Registered',
            'value': (stats.statusCounts['Registered'] ?? 0).toString(),
            'icon': Icons.app_registration_rounded,
            'color': AppThemes.greenAccent,
            'change': '+8%',
          },
          {
            'title': 'Connected',
            'value': (stats.statusCounts['Connected'] ?? 0).toString(),
            'icon': Icons.phone_in_talk_rounded,
            'color': AppThemes.purpleAccent,
            'change': '+5%',
          },
          {
            'title': 'Pending',
            'value': (stats.statusCounts['Pending'] ?? 0).toString(),
            'icon': Icons.pending_actions_rounded,
            'color': AppThemes.orangeAccent,
            'change': '-2%',
          },
        ];
        final stat = statData[index];
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
      constraints: BoxConstraints(minHeight: screenWidth * 0.3),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  vertical: screenWidth * 0.01,
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

          // Content section with minimal spacing
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
                ),
              ),
              SizedBox(height: screenWidth * 0.01), // Minimal spacing
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
        ],
      ),
    );
  }

  Widget _buildDashboardShimmer(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 4;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCardShimmer(isDarkMode),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: screenWidth * 0.03,
                crossAxisSpacing: screenWidth * 0.03,
                childAspectRatio: screenWidth < 400 ? 1.1 : 1.2,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildStatCardShimmer(isDarkMode, screenWidth);
              },
            ),
            const SizedBox(height: 24),
            _buildQuickActionsShimmer(isDarkMode),
            const SizedBox(height: 24),
            _buildRecentActivityShimmer(isDarkMode),
            const SizedBox(height: 100), // Space for floating nav
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCardShimmer(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 16,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 24,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardShimmer(bool isDarkMode, double screenWidth) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        constraints: BoxConstraints(minHeight: screenWidth * 0.3),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
                Container(
                  width: screenWidth * 0.08,
                  height: screenWidth * 0.04,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.07,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.035,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsShimmer(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 24,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityShimmer(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 24,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message, bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildWelcomeCard(isDarkMode),
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
          child: Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, color: AppThemes.redAccent, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Error loading dashboard data',
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.white
                        : AppThemes.lightPrimaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: isDarkMode
                        ? AppThemes.darkSecondaryText
                        : AppThemes.lightSecondaryText,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    int? managerId;
                    if (authState is Authenticated) {
                      managerId = int.tryParse(authState.user?.id ?? '');
                    }
                    context.read<ManagerDashboardBloc>().add(
                      LoadManagerStats(managerId: managerId),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemes.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ],
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
            _buildActionCard('View All Leads', Icons.list_alt_rounded, () {
              setState(() {
                _currentIndex = 1; // Navigate to All Leads tab
              });
            }, isDarkMode),
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            _buildActionCard('Stale Leads', Icons.warning_amber_rounded, () {
              setState(() {
                _currentIndex = 2; // Navigate to Stale Leads tab
              });
            }, isDarkMode),
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            _buildActionCard('Notifications', Icons.notifications_rounded, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
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
                ? AppThemes.darkBorder.withValues(alpha: 0.3)
                : AppThemes.lightBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(width < 360 ? 12 : 16),
              decoration: BoxDecoration(
                color: AppThemes.primaryColor.withValues(alpha: 0.1),
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
                Icons.leaderboard_rounded,
                'Lead status updated',
                'Lead #1234 status changed to Demo Attended',
                '5 hours ago',
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                Icons.person_add_rounded,
                'New lead assigned',
                'Lead #5678 assigned to BA Specialist',
                '2 hours ago',
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
              color: AppThemes.primaryColor.withValues(alpha: 0.1),
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
}

class ManagerAllLeadsWidget extends StatefulWidget {
  const ManagerAllLeadsWidget({super.key});

  @override
  State<ManagerAllLeadsWidget> createState() => _ManagerAllLeadsWidgetState();
}

class _ManagerAllLeadsWidgetState extends State<ManagerAllLeadsWidget> {
  bool _hasLoadedInitialData = false;

  // Filters
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedStatus;

  final List<String> _statusOptions = [
    'Pending',
    'Connected',
    'Not Connected',
    'Follow-up Planned',
    'Follow-up Completed',
    'Registered',
  ];

  @override
  void initState() {
    super.initState();
    // Load initial data will be handled in the build method with addPostFrameCallback
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showFilterModal(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppThemes.darkCardBackground : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Leads',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppThemes.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Lead Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.flag),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ..._statusOptions.map(
                  (status) =>
                      DropdownMenuItem(value: status, child: Text(status)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: _selectedDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _selectedDate = null),
                        )
                      : null,
                ),
                child: Text(
                  _selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                      : 'Select Date',
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Apply filters would need to be implemented
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemes.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state.isDarkMode;
        return _buildBody(isDarkMode);
      },
    );
  }

  Widget _buildBody(bool isDarkMode) {
    return BlocBuilder<LeadsBloc, LeadsState>(
      builder: (context, leadsState) {
        // Load leads data only when needed (first time)
        if (!_hasLoadedInitialData &&
            leadsState.leads.isEmpty &&
            !leadsState.isLoading &&
            leadsState.error == null) {
          // Use addPostFrameCallback to avoid calling during build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<LeadsBloc>().add(LoadAllLeads());
            setState(() {
              _hasLoadedInitialData = true;
            });
          });
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Reset the flag and load fresh data
            setState(() {
              _hasLoadedInitialData = false;
            });
            context.read<LeadsBloc>().add(LoadAllLeads());
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: Builder(
            builder: (context) {
              if (leadsState.isLoading && leadsState.leads.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (leadsState.error != null && leadsState.leads.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${leadsState.error}'),
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

              final leads = leadsState.leads;

              return GenericTableView<Lead>(
                title: 'All Leads',
                data: leads,
                columns: [
                  GenericTableColumn(
                    title: 'ID',
                    value: (lead) => lead.id.toString(),
                    width: 60,
                  ),
                  GenericTableColumn(
                    title: 'Name',
                    value: (lead) => lead.name,
                    width: 150,
                  ),
                  GenericTableColumn(
                    title: 'Phone',
                    value: (lead) => lead.phone,
                    width: 120,
                  ),
                  GenericTableColumn(
                    title: 'Email',
                    value: (lead) => lead.email,
                    width: 150,
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
                        color: AppThemes.getStatusColor(lead.status).withValues(alpha: 0.1),
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
                  GenericTableColumn(
                    title: 'Created',
                    value: (lead) => lead.createdAt.isNotEmpty
                        ? DateFormat('MMM d, y').format(DateTime.parse(lead.createdAt))
                        : 'N/A',
                    width: 120,
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
                ],
                onRowTap: (lead) {
                  _showLeadDetails(lead);
                },
                showSearch: true,
                showFilter: true,
                showExport: true,
                onFilterChanged: (filter) {
                  // Handle filter change if needed
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header shimmer
            Container(
              height: 60,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Table rows shimmer
            for (int i = 0; i < 10; i++)
              Container(
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppThemes.redAccent,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading leads',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppThemes.darkSecondaryText : AppThemes.lightSecondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasLoadedInitialData = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: isDarkMode ? Colors.white54 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No leads found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppThemes.darkSecondaryText : AppThemes.lightSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  void _showLeadDetails(Lead lead) {
    // Create a stateful widget for the bottom sheet to manage history data
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          _LeadDetailsBottomSheet(lead: lead, leadService: ServiceLocator.leadService),
    );
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
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
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
                    _buildDetailRow('Email', widget.lead.email),
                    _buildDetailRow('Phone', widget.lead.phone),
                    _buildDetailRow('Education', widget.lead.education),
                    _buildDetailRow('Experience', widget.lead.experience),
                    _buildDetailRow('Location', widget.lead.location),
                    _buildDetailRow('Current Status', widget.lead.status),
                    _buildDetailRow('Feedback', widget.lead.feedback),
                    _buildDetailRow('Created At', widget.lead.createdAt),
                    _buildDetailRow('Owner', widget.lead.ownerName),
                    _buildDetailRow('Assigned To', widget.lead.assignedName),
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
                        physics: const ClampingScrollPhysics(),
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
            width: 120,
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
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
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
            'Updated by: ${history.updatedBy} (${history.role})',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class StaleLeadsWidget extends StatefulWidget {
  const StaleLeadsWidget({super.key});

  @override
  State<StaleLeadsWidget> createState() => _StaleLeadsWidgetState();
}

class _StaleLeadsWidgetState extends State<StaleLeadsWidget> {
  late LeadService _leadService;
  List<Lead> _leads = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  List<UserRole> _baSpecialists = [];

  bool _hasLoadedInitialData = false;

  @override
  void initState() {
    super.initState();
    _leadService = ServiceLocator.leadService;
    _loadBASpecialists();
    _scrollController.addListener(_onScroll);
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeads();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _loadLeads();
    }
  }

  Future<void> _loadBASpecialists() async {
    try {
      final specialists = await _leadService.getBASpecialists();
      setState(() {
        _baSpecialists = specialists;
      });
    } catch (e) {
      // Handle error silently or show snackbar
      print('Error loading BA specialists: $e');
    }
  }

  Future<void> _loadLeads() async {
    if (_isLoading && _page > 1) return;

    setState(() {
      _isLoading = true;
      if (_page == 1) _error = null;
    });

    try {
      final leads = await _leadService.getStaleLeads(page: _page);
      setState(() {
        if (_page == 1) {
          _leads = leads;
        } else {
          _leads.addAll(leads);
        }
        _hasMore = leads.length >= 20;
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _reassignLead(Lead lead) async {
    UserRole? selectedUser;
    final result = await showDialog<UserRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reassign Lead'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reassign ${lead.name} to:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              items: _baSpecialists
                  .map(
                    (user) =>
                        DropdownMenuItem(value: user, child: Text(user.name)),
                  )
                  .toList(),
              onChanged: (value) {
                selectedUser = value;
              },
              decoration: const InputDecoration(
                labelText: 'Select Specialist',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedUser),
            child: const Text('Reassign'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        // Create updated lead object
        final updatedLead = Lead(
          id: lead.id,
          name: lead.name,
          phone: lead.phone,
          email: lead.email,
          status: lead.status,
          feedback: 'Reassigned from stale status',
          assignedTo: int.tryParse(result.id),
          // Required fields - passing current values or empty strings if not available
          ownerName: lead.ownerName,
          assignedName: lead.assignedName,
          latestHistory: lead.latestHistory,
          // Copy other fields...
          education: lead.education,
          experience: lead.experience,
          location: lead.location,
          createdAt: lead.createdAt,
        );

        await _leadService.updateLead(updatedLead);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lead reassigned successfully')),
          );
        }

        // Refresh list
        _page = 1;
        _loadLeads();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to reassign: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        return _buildBody(isDarkMode);
      },
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (_isLoading && _leads.isEmpty) {
      return _buildShimmerLoading(isDarkMode);
    }

    if (_error != null && _leads.isEmpty) {
      return _buildErrorView(_error!, isDarkMode);
    }

    if (_leads.isEmpty) {
      return _buildEmptyView(isDarkMode);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _page = 1;
        await _loadLeads();
      },
      child: GenericTableView<Lead>(
        title: 'Stale Leads',
        data: _leads,
        columns: [
          GenericTableColumn(
            title: 'ID',
            value: (lead) => lead.id.toString(),
            width: 60,
          ),
          GenericTableColumn(
            title: 'Name',
            value: (lead) => lead.name,
            width: 150,
          ),
          GenericTableColumn(
            title: 'Phone',
            value: (lead) => lead.phone,
            width: 120,
          ),
          GenericTableColumn(
            title: 'Email',
            value: (lead) => lead.email,
            width: 150,
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
                color: AppThemes.getStatusColor(lead.status).withValues(alpha: 0.1),
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
          GenericTableColumn(
            title: 'Created',
            value: (lead) => DateFormat('MMM d, y').format(DateTime.parse(lead.createdAt)),
            width: 120,
          ),
          GenericTableColumn(
            title: 'Assigned To',
            value: (lead) => lead.assignedName,
            width: 120,
          ),
        ],
        onRowTap: (lead) {
          // Handle row tap if needed
        },
        onRowReassign: (lead) {
          _reassignLead(lead);
        },
        showSearch: true,
        showFilter: true,
        showExport: true,
      ),
    );
  }

  Widget _buildShimmerLoading(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header shimmer
            Container(
              height: 60,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Table rows shimmer
            for (int i = 0; i < 10; i++)
              Container(
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppThemes.redAccent,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading stale leads',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppThemes.darkSecondaryText : AppThemes.lightSecondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _page = 1;
              _loadLeads();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: isDarkMode ? Colors.white54 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No stale leads found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All leads are up to date',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppThemes.darkSecondaryText : AppThemes.lightSecondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
