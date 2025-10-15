import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onLeadingPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        // Create a list of actions, starting with any existing actions
        List<Widget> appActions = [];
        if (actions != null) {
          appActions.addAll(actions!);
        }
        
        // Add the theme toggle button
        appActions.add(
          IconButton(
            icon: Icon(
              themeState.currentThemeMode == 'light' 
                ? Icons.dark_mode 
                : themeState.currentThemeMode == 'dark' 
                  ? Icons.brightness_auto 
                  : Icons.light_mode,
            ),
            onPressed: () {
              context.read<ThemeBloc>().add(ToggleTheme());
            },
            tooltip: themeState.currentThemeMode == 'light' 
              ? 'Switch to dark mode' 
              : themeState.currentThemeMode == 'dark' 
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
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
          actions: appActions,
          elevation: Theme.of(context).appBarTheme.elevation,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}