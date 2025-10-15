import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String userName;
  final String userEmail;
  final List<Widget>? actions;

  const ModernAppBar({
    super.key,
    required this.title,
    required this.userName,
    required this.userEmail,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        final currentThemeMode = themeState.currentThemeMode;

        // Create a list of actions, starting with any existing actions
        List<Widget> appActions = [];
        if (actions != null) {
          appActions.addAll(actions!);
        }

        // Add notification button
        appActions.add(
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              color: isDarkMode ? Colors.white : Colors.white,
            ),
            onPressed: () {
              // Show notifications
            },
            tooltip: 'Notifications',
          ),
        );

        // Add theme toggle button
        appActions.add(
          IconButton(
            icon: Icon(
              currentThemeMode == 'light'
                  ? Icons.dark_mode_outlined
                  : currentThemeMode == 'dark'
                      ? Icons.brightness_auto_outlined
                      : Icons.light_mode_outlined,
              color: isDarkMode ? Colors.white : Colors.white,
            ),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleTheme());
            },
            tooltip: currentThemeMode == 'light'
                ? 'Switch to dark mode'
                : currentThemeMode == 'dark'
                    ? 'Switch to system theme'
                    : 'Switch to light mode',
          ),
        );

        return AppBar(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: appActions,
          elevation: 0,
          backgroundColor: const Color(0xFF00BCD4),
          foregroundColor: Colors.white,
          centerTitle: false,
        );
      },
    );
  }
}