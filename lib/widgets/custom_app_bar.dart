import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBackPress;

  const CustomAppBar({super.key, required this.title, this.onBackPress});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;
        final appBarHeight = width < 360 ? 60.0 : 70.0;
        final horizontalPadding = width < 360 ? 12.0 : 16.0;

        return Container(
          width: double.infinity,
          height: appBarHeight,
          margin: EdgeInsets.only(top: height * 0.05),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: isDarkMode
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Back button
              if (onBackPress != null)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: isDarkMode
                          ? Colors.white
                          : const Color(0xFF1A1A1A),
                      size: 18,
                    ),
                    onPressed: onBackPress,
                    padding: EdgeInsets.zero,
                  ),
                ),

              const SizedBox(width: 12),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Profile Avatar
              _buildProfileAvatar(context, isDarkMode),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileAvatar(BuildContext context, bool isDarkMode) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String userName = 'User';
        if (authState is Authenticated && authState.user != null) {
          userName = authState.user!.name;
        }

        return GestureDetector(
          onTap: () => _showProfileMenu(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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
}
