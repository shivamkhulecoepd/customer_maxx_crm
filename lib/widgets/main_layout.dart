import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/widgets/app_drawer.dart';

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
                  child: SizedBox(width: double.infinity, child: body),
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
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
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

  Widget _buildModernDrawer(BuildContext context, bool isDarkMode) {
    return const ModernDrawer();
  }

  // Drawer implementation moved to ModernDrawer widget
}
