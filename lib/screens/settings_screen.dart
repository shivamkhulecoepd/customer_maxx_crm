import 'package:customer_maxx_crm/main.dart';
import 'package:customer_maxx_crm/screens/admin/admin_dashboard.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/ba_specialist_dashboard.dart';
import 'package:customer_maxx_crm/screens/lead_manager/lead_manager_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/widgets/main_layout.dart';
import 'package:customer_maxx_crm/screens/auth/auth_screen.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';

class ModernSettingsScreen extends StatefulWidget {
  const ModernSettingsScreen({super.key});

  @override
  State<ModernSettingsScreen> createState() => _ModernSettingsScreenState();
}

class _ModernSettingsScreenState extends State<ModernSettingsScreen> {
  String _userName = '';
  String _userEmail = '';
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  void initState() {
    super.initState();
    // Get user info from auth bloc
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = BlocProvider.of<AuthBloc>(context).state;
        if (authState is Authenticated && authState.user != null) {
          setState(() {
            _userName = authState.user!.name;
            _userEmail = authState.user!.email;
          });
        }
      }
    });
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
          body: RefreshIndicator(
            onRefresh: () async {
              // Refresh settings
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppThemes.getPrimaryGradient(),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppThemes.getElevatedShadow(isDarkMode),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.settings_outlined,
                            size: 48,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Customize your experience and manage your account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Account Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileCard(context, isDarkMode),
                    const SizedBox(height: 20),
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildThemeCard(context, themeState),
                    const SizedBox(height: 20),
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildNotificationsCard(context),
                    const SizedBox(height: 20),
                    const Text(
                      'Security',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSecurityCard(context),
                    const SizedBox(height: 20),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
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
      // height: appBarHeight,
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     colors: isDarkMode
      //         ? [const Color(0xFF1A1A1A), const Color(0xFF2D2D2D)]
      //         : [Colors.white, const Color(0xFFF8FAFC)],
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //   ),
      //   boxShadow: [
      //     BoxShadow(
      //       color: isDarkMode
      //           ? Colors.black.withValues(alpha: 0.3)
      //           : Colors.grey.withValues(alpha: 0.1),
      //       blurRadius: width < 360 ? 8 : 10,
      //       offset: const Offset(0, 2),
      //     ),
      //   ],
      // ),
      decoration: BoxDecoration(color: Colors.transparent),
      // child: Padding(
      //   padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          _buildIconButton(
            context,
            Icons.arrow_back_ios_rounded,
            // () => _navigateBack(context),
            () => Navigator.of(context).pop(),
            isDarkMode,
          ),

          SizedBox(width: width < 360 ? 8 : 12),

          // Title
          Expanded(
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: width < 360 ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Actions
          // if (actions != null) ...actions!,

          // Theme Toggle
          _buildIconButton(
            context,
            isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            () => context.read<ThemeBloc>().add(ToggleTheme()),
            isDarkMode,
          ),
        ],
      ),
      // ),
    );
  }

  void _navigateBack(BuildContext context) {
    // Check if there's a previous route to go back to
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      // If no previous route, navigate to the main dashboard based on user role
      // This handles the case when user came directly from drawer
      final authState = BlocProvider.of<AuthBloc>(context).state;
      if (authState is Authenticated && authState.user != null) {
        final userRole = authState.user!.role;
        switch (userRole) {
          case 'Admin':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ModernAdminDashboard(),
              ),
            );
            break;
          case 'Lead Manager':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ModernLeadManagerDashboard(),
              ),
            );
            break;
          case 'BA Specialist':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ModernBASpecialistDashboard(),
              ),
            );
            break;
          default:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AuthWrapper()),
            );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
        );
      }
    }
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

  Widget _buildProfileCard(BuildContext context, bool isDarkMode) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(
                    0xFF00BCD4,
                  ).withValues(alpha: 0.1),
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: Color(0xFF00BCD4),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Edit profile functionality
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context,
              Icons.person_outline,
              'Edit Profile',
              'Update your personal information',
              () {
                // Navigate to edit profile
              },
            ),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context,
              Icons.lock_outline,
              'Change Password',
              'Update your password',
              () {
                // Navigate to change password
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, ThemeState themeState) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingsItem(
              context,
              Icons.brightness_6_outlined,
              'Theme',
              themeState.currentThemeMode == 'light'
                  ? 'Light mode'
                  : themeState.currentThemeMode == 'dark'
                  ? 'Dark mode'
                  : 'System default',
              () {
                _showThemeSelectionDialog(context, themeState);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Enable Notifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  activeThumbColor: const Color(0xFF00BCD4),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Email Notifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() {
                      _emailNotifications = value;
                    });
                  },
                  activeThumbColor: const Color(0xFF00BCD4),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Push Notifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                  activeThumbColor: const Color(0xFF00BCD4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingsItem(
              context,
              Icons.lock_outline,
              'Two-Factor Authentication',
              'Add extra security to your account',
              () {
                // Navigate to 2FA setup
              },
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildSettingsItem(
              context,
              Icons.history_outlined,
              'Login History',
              'View your recent login activity',
              () {
                // Navigate to login history
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF00BCD4)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.grey[600],
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showThemeSelectionDialog(BuildContext context, ThemeState themeState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                'Light',
                themeState.currentThemeMode == 'light',
                () {
                  context.read<ThemeBloc>().add(ThemeChanged('light'));
                  Navigator.pop(context);
                },
              ),
              _buildThemeOption(
                context,
                'Dark',
                themeState.currentThemeMode == 'dark',
                () {
                  context.read<ThemeBloc>().add(ThemeChanged('dark'));
                  Navigator.pop(context);
                },
              ),
              _buildThemeOption(
                context,
                'System Default',
                themeState.currentThemeMode == 'system',
                () {
                  context.read<ThemeBloc>().add(ThemeChanged('system'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF00BCD4))
          : null,
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          bool? shouldLogout = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Logout'),
                  ),
                ],
              );
            },
          );

          // If user confirmed logout
          if (shouldLogout == true) {
            // Store context in a local variable before async operation
            final currentContext = context;
            currentContext.read<AuthBloc>().add(LogoutRequested());

            // Clear all navigation and go to root
            if (currentContext.mounted) {
              Navigator.of(
                currentContext,
                rootNavigator: true,
              ).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) =>
                      const ModernAuthScreen(authMode: AuthMode.login),
                ),
                (route) => false,
              );
            }
          }
        },
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text('Logout', style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
// import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
// import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
// import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
// import 'package:customer_maxx_crm/widgets/main_layout.dart';
// import 'package:customer_maxx_crm/screens/auth/auth_screen.dart';
// import 'package:customer_maxx_crm/utils/theme_utils.dart';

// class ModernSettingsScreen extends StatefulWidget {
//   const ModernSettingsScreen({super.key});

//   @override
//   State<ModernSettingsScreen> createState() => _ModernSettingsScreenState();
// }

// class _ModernSettingsScreenState extends State<ModernSettingsScreen> {
//   String _userName = '';
//   String _userEmail = '';
//   bool _notificationsEnabled = true;
//   bool _emailNotifications = true;
//   bool _pushNotifications = true;

//   @override
//   void initState() {
//     super.initState();
//     // Get user info from auth bloc
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         final authState = BlocProvider.of<AuthBloc>(context).state;
//         if (authState is Authenticated && authState.user != null) {
//           setState(() {
//             _userName = authState.user!.name;
//             _userEmail = authState.user!.email;
//           });
//         }
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ModernLayout(
//       title: 'Settings',
//       body: BlocBuilder<ThemeBloc, ThemeState>(
//         builder: (context, themeState) {
//           final isDarkMode = themeState.isDarkMode;
          
//           return RefreshIndicator(
//             onRefresh: () async {
//               // Refresh settings
//               await Future.delayed(const Duration(seconds: 1));
//             },
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header Section
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(24),
//                       decoration: BoxDecoration(
//                         gradient: AppThemes.getPrimaryGradient(),
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: AppThemes.getElevatedShadow(isDarkMode),
//                       ),
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.settings_outlined,
//                             size: 48,
//                             color: Colors.white,
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'Settings',
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 8),
//                           const Text(
//                             'Customize your experience and manage your account',
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white70,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
                    
//                     const Text(
//                       'Account Settings',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     _buildProfileCard(context, isDarkMode),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'Preferences',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     _buildThemeCard(context, themeState),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'Notifications',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     _buildNotificationsCard(context),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'Security',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     _buildSecurityCard(context),
//                     const SizedBox(height: 20),
//                     _buildLogoutButton(context),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildProfileCard(BuildContext context, bool isDarkMode) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundColor: const Color(0xFF00BCD4).withValues(alpha: 0.1),
//                   child: Text(
//                     _userName.isNotEmpty ? _userName[0].toUpperCase() : 'A',
//                     style: const TextStyle(
//                       color: Color(0xFF00BCD4),
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _userName,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _userEmail,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: isDarkMode ? Colors.white70 : Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.edit),
//                   onPressed: () {
//                     // Edit profile functionality
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             const Divider(),
//             const SizedBox(height: 16),
//             _buildSettingsItem(
//               context,
//               Icons.person_outline,
//               'Edit Profile',
//               'Update your personal information',
//               () {
//                 // Navigate to edit profile
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildSettingsItem(
//               context,
//               Icons.lock_outline,
//               'Change Password',
//               'Update your password',
//               () {
//                 // Navigate to change password
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildThemeCard(BuildContext context, ThemeState themeState) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildSettingsItem(
//               context,
//               Icons.brightness_6_outlined,
//               'Theme',
//               themeState.currentThemeMode == 'light'
//                   ? 'Light mode'
//                   : themeState.currentThemeMode == 'dark'
//                       ? 'Dark mode'
//                       : 'System default',
//               () {
//                 _showThemeSelectionDialog(context, themeState);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationsCard(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Enable Notifications',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Switch(
//                   value: _notificationsEnabled,
//                   onChanged: (value) {
//                     setState(() {
//                       _notificationsEnabled = value;
//                     });
//                   },
//                   activeThumbColor: const Color(0xFF00BCD4),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             const Divider(),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Email Notifications',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Switch(
//                   value: _emailNotifications,
//                   onChanged: (value) {
//                     setState(() {
//                       _emailNotifications = value;
//                     });
//                   },
//                   activeThumbColor: const Color(0xFF00BCD4),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Push Notifications',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 Switch(
//                   value: _pushNotifications,
//                   onChanged: (value) {
//                     setState(() {
//                       _pushNotifications = value;
//                     });
//                   },
//                   activeThumbColor: const Color(0xFF00BCD4),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSecurityCard(BuildContext context) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildSettingsItem(
//               context,
//               Icons.lock_outline,
//               'Two-Factor Authentication',
//               'Add extra security to your account',
//               () {
//                 // Navigate to 2FA setup
//               },
//             ),
//             const SizedBox(height: 16),
//             const Divider(),
//             const SizedBox(height: 16),
//             _buildSettingsItem(
//               context,
//               Icons.history_outlined,
//               'Login History',
//               'View your recent login activity',
//               () {
//                 // Navigate to login history
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSettingsItem(
//     BuildContext context,
//     IconData icon,
//     String title,
//     String subtitle,
//     VoidCallback onTap,
//   ) {
//     final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

//     return ListTile(
//       leading: Container(
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(
//           icon,
//           color: const Color(0xFF00BCD4),
//         ),
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: TextStyle(
//           color: isDarkMode ? Colors.white70 : Colors.grey[600],
//           fontSize: 12,
//         ),
//       ),
//       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//       onTap: onTap,
//     );
//   }

//   void _showThemeSelectionDialog(
//       BuildContext context, ThemeState themeState) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Select Theme'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildThemeOption(
//                 context,
//                 'Light',
//                 themeState.currentThemeMode == 'light',
//                 () {
//                   context.read<ThemeBloc>().add(ThemeChanged('light'));
//                   Navigator.pop(context);
//                 },
//               ),
//               _buildThemeOption(
//                 context,
//                 'Dark',
//                 themeState.currentThemeMode == 'dark',
//                 () {
//                   context.read<ThemeBloc>().add(ThemeChanged('dark'));
//                   Navigator.pop(context);
//                 },
//               ),
//               _buildThemeOption(
//                 context,
//                 'System Default',
//                 themeState.currentThemeMode == 'system',
//                 () {
//                   context.read<ThemeBloc>().add(ThemeChanged('system'));
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildThemeOption(BuildContext context, String title, bool isSelected,
//       VoidCallback onTap) {
//     return ListTile(
//       title: Text(title),
//       trailing: isSelected
//           ? const Icon(Icons.check, color: Color(0xFF00BCD4))
//           : null,
//       onTap: onTap,
//     );
//   }

//   Widget _buildLogoutButton(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton.icon(
//         onPressed: () async {
//           // Show confirmation dialog
//           bool? shouldLogout = await showDialog<bool>(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Text('Logout'),
//                 content: const Text('Are you sure you want to logout?'),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(false),
//                     child: const Text('Cancel'),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(true),
//                     child: const Text('Logout'),
//                   ),
//                 ],
//               );
//             },
//           );

//           // If user confirmed logout
//           if (shouldLogout == true) {
//             // Store context in a local variable before async operation
//             final currentContext = context;
//             currentContext.read<AuthBloc>().add(LogoutRequested());

//             // Clear all navigation and go to root
//             if (currentContext.mounted) {
//               Navigator.of(currentContext, rootNavigator: true).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (context) => const ModernAuthScreen(authMode: AuthMode.login)),
//                 (route) => false,
//               );
//             }
//           }
//         },
//         icon: const Icon(Icons.logout, color: Colors.white),
//         label: const Text(
//           'Logout',
//           style: TextStyle(color: Colors.white),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.red,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
// }