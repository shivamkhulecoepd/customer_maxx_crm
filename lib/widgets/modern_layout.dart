import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';

class ModernLayout extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showDrawer;
  final VoidCallback? onBackPressed;

  const ModernLayout({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showDrawer = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;

        return Scaffold(
          backgroundColor: isDarkMode
              ? const Color(0xFF0A0A0A)
              : const Color(0xFFF8FAFC),
          drawer: showDrawer ? _buildModernDrawer(context, isDarkMode) : null,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          body: SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(context, isDarkMode),
                // Use Expanded to ensure the body takes available space
                Expanded(
                  child: Container(width: double.infinity, child: body),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomAppBar(BuildContext context, bool isDarkMode) {
    final width = MediaQuery.of(context).size.width;
    final appBarHeight = width < 360 ? 60.0 : 70.0;
    final horizontalPadding = width < 360 ? 12.0 : 16.0;

    return Container(
      height: appBarHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
              : [Colors.white, const Color(0xFFF8FAFC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: width < 360 ? 8 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
              )
            else if (onBackPressed != null)
              _buildIconButton(
                context,
                Icons.arrow_back_ios_rounded,
                onBackPressed!,
                isDarkMode,
              ),

            SizedBox(width: width < 360 ? 8 : 12),

            // Title
            Expanded(
              child: Text(
                title,
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
            ? Colors.white.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
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
                  color: const Color(0xFF00BCD4).withOpacity(0.3),
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
                color: Colors.grey.withOpacity(0.3),
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

  Widget _buildModernDrawer(BuildContext context, bool isDarkMode) {
    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      child: Column(
        children: [
          _buildDrawerHeader(context, isDarkMode),
          Expanded(child: _buildDrawerItems(context, isDarkMode)),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, bool isDarkMode) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String userName = 'User';
        String userRole = 'Role';

        if (authState is Authenticated && authState.user != null) {
          userName = authState.user!.name;
          userRole = authState.user!.role;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = MediaQuery.of(context).size.height;
            final avatarSize = screenHeight * 0.07;
            final nameFontSize = screenHeight * 0.022;
            final roleFontSize = screenHeight * 0.018;

            return Container(
              width: double.infinity,
              // Make height adaptive to device size
              height: screenHeight * 0.25,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false, // Avoid extra padding that causes overflow
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centered instead of end
                    children: [
                      Container(
                        width: avatarSize,
                        height: avatarSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: avatarSize * 0.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.015),
                      Flexible(
                        child: Text(
                          userName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: nameFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          userRole,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: roleFontSize,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDrawerItems(BuildContext context, bool isDarkMode) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String userRole = 'User';
        if (authState is Authenticated && authState.user != null) {
          userRole = authState.user!.role;
        }

        return ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _buildDrawerItem(
              context,
              Icons.dashboard_rounded,
              'Dashboard',
              () => _navigateToDashboard(context, userRole),
              isDarkMode,
            ),

            if (userRole == 'Admin') ...[
              _buildDrawerItem(
                context,
                Icons.people_rounded,
                'User Management',
                () => Navigator.pushNamed(context, '/user-management'),
                isDarkMode,
              ),
              _buildDrawerItem(
                context,
                Icons.leaderboard_rounded,
                'All Leads',
                () => Navigator.pushNamed(context, '/all-leads'),
                isDarkMode,
              ),
            ],

            if (userRole == 'Lead Manager') ...[
              _buildDrawerItem(
                context,
                Icons.add_circle_rounded,
                'Add Lead',
                () => Navigator.pushNamed(context, '/add-lead'),
                isDarkMode,
              ),
              _buildDrawerItem(
                context,
                Icons.visibility_rounded,
                'View Leads',
                () => Navigator.pushNamed(context, '/view-leads'),
                isDarkMode,
              ),
            ],

            if (userRole == 'BA Specialist') ...[
              _buildDrawerItem(
                context,
                Icons.app_registration_rounded,
                'Registered Leads',
                () => Navigator.pushNamed(context, '/registered-leads'),
                isDarkMode,
              ),
            ],

            const Divider(height: 32),

            _buildDrawerItem(
              context,
              Icons.settings_rounded,
              'Settings',
              () => Navigator.pushNamed(context, '/settings'),
              isDarkMode,
            ),
            _buildDrawerItem(
              context,
              Icons.help_rounded,
              'Help & Support',
              () {},
              isDarkMode,
            ),
            _buildDrawerItem(context, Icons.logout_rounded, 'Logout', () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
            }, isDarkMode),
          ],
        );
      },
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDarkMode ? Colors.white70 : Colors.grey[700],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToDashboard(BuildContext context, String userRole) {
    Navigator.pop(context);
    // Navigation logic based on role
  }
}
