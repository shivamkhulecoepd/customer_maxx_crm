import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_maxx_crm/providers/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onLeadingPressed;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.onLeadingPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Create a list of actions, starting with any existing actions
    List<Widget> appActions = [];
    if (actions != null) {
      appActions.addAll(actions!);
    }
    
    // Add the theme toggle button
    appActions.add(
      IconButton(
        icon: Icon(
          themeProvider.currentThemeMode == 'light' 
            ? Icons.dark_mode 
            : themeProvider.currentThemeMode == 'dark' 
              ? Icons.brightness_auto 
              : Icons.light_mode,
        ),
        onPressed: () {
          themeProvider.toggleTheme();
        },
        tooltip: themeProvider.currentThemeMode == 'light' 
          ? 'Switch to dark mode' 
          : themeProvider.currentThemeMode == 'dark' 
            ? 'Switch to system theme' 
            : 'Switch to light mode',
      ),
    );

    return AppBar(
      leading: onLeadingPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onLeadingPressed,
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: appActions,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}