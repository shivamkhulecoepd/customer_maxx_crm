import 'package:flutter/material.dart';

class ModernNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userRole;

  const ModernNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final items = _getNavigationItems(userRole);

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Responsive scaling
    final navHeight = height * 0.09; // ~80 on avg device
    final horizontalPadding = width * 0.04;
    final verticalPadding = height * 0.01;
    final blur = width * 0.025;

    return Container(
      height: navHeight,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            blurRadius: blur,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return _buildNavigationItem(
                context,
                item,
                isSelected,
                () => onTap(index),
                isDarkMode,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    NavigationItem item,
    bool isSelected,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final iconSize = width * 0.06; // 24 on 400px width
    final fontSize = width * 0.03; // 12 on 400px width
    final padding = width * 0.04;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: padding * 0.5, vertical: height * 0.01),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00BCD4).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(width * 0.04),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(width * 0.02),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF00BCD4)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
                child: Icon(
                  item.icon,
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? Colors.white54 : Colors.grey[600]),
                  size: iconSize,
                ),
              ),
              SizedBox(height: height * 0.005),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF00BCD4)
                      : (isDarkMode ? Colors.white54 : Colors.grey[600]),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<NavigationItem> _getNavigationItems(String role) {
    final normalizedRole = role.toLowerCase();

    if (normalizedRole.contains('admin')) {
      return [
        NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        NavigationItem(icon: Icons.people_rounded, label: 'Users'),
        NavigationItem(icon: Icons.leaderboard_rounded, label: 'Leads'),
        NavigationItem(icon: Icons.analytics_rounded, label: 'Analytics'),
      ];
    } else if (normalizedRole.contains('lead')) {
      return [
        NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        NavigationItem(icon: Icons.add_circle_rounded, label: 'Add Lead'),
        NavigationItem(icon: Icons.visibility_rounded, label: 'View Leads'),
        NavigationItem(icon: Icons.analytics_rounded, label: 'Reports'),
      ];
    } else if (normalizedRole.contains('ba') || normalizedRole.contains('specialist')) {
      return [
        NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        NavigationItem(icon: Icons.app_registration_rounded, label: 'Registered'),
        NavigationItem(icon: Icons.task_rounded, label: 'Tasks'),
        NavigationItem(icon: Icons.person_rounded, label: 'Profile'),
      ];
    } else {
      return [NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard')];
    }
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  NavigationItem({required this.icon, required this.label});
}

class ModernBottomNavigation extends StatefulWidget {
  final String userRole;
  final Function(int) onPageChanged;

  const ModernBottomNavigation({
    super.key,
    required this.userRole,
    required this.onPageChanged,
  });

  @override
  State<ModernBottomNavigation> createState() => _ModernBottomNavigationState();
}

class _ModernBottomNavigationState extends State<ModernBottomNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ModernNavigationBar(
      currentIndex: _currentIndex,
      userRole: widget.userRole,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        widget.onPageChanged(index);
      },
    );
  }
}

// Floating Navigation Bar (responsive)
class FloatingNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String userRole;

  const FloatingNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final items = _getNavigationItems(userRole);

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: height * 0.01,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.2),
            blurRadius: width * 0.05,
            offset: Offset(0, height * 0.01),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == currentIndex;

          return _buildFloatingNavItem(
            context,
            item,
            isSelected,
            () => onTap(index),
            isDarkMode,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFloatingNavItem(
    BuildContext context,
    NavigationItem item,
    bool isSelected,
    VoidCallback onTap,
    bool isDarkMode,
  ) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    final iconSize = width * 0.06;
    final fontSize = width * 0.035;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: width * 0.005),
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.03,
            vertical: width * 0.03,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent,
            borderRadius: BorderRadius.circular(width * 0.05),
          ),
          child: isSelected
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: Colors.white, size: iconSize),
                    SizedBox(width: width * 0.01),
                    Flexible(
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: fontSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                )
              : Icon(
                  item.icon,
                  color: isDarkMode ? Colors.white54 : Colors.grey[600],
                  size: iconSize,
                ),
        ),
      ),
    );
  }

  List<NavigationItem> _getNavigationItems(String role) {
    final normalizedRole = role.toLowerCase();

    if (normalizedRole.contains('admin')) {
      return [
        NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        NavigationItem(icon: Icons.people_rounded, label: 'Users'),
        NavigationItem(icon: Icons.leaderboard_rounded, label: 'Leads'),
        NavigationItem(icon: Icons.analytics_rounded, label: 'Analytics'),
      ];
    } else if (normalizedRole.contains('lead')) {
      return [
        NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        NavigationItem(icon: Icons.add_circle_rounded, label: 'Add'),
        NavigationItem(icon: Icons.visibility_rounded, label: 'View'),
        NavigationItem(icon: Icons.analytics_rounded, label: 'Reports'),
      ];
    } else if (normalizedRole.contains('ba') || normalizedRole.contains('specialist')) {
      return [
        NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
        NavigationItem(icon: Icons.app_registration_rounded, label: 'Leads'),
        NavigationItem(icon: Icons.task_rounded, label: 'Tasks'),
        NavigationItem(icon: Icons.person_rounded, label: 'Profile'),
      ];
    } else {
      return [NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard')];
    }
  }
}




// import 'package:flutter/material.dart';


// class ModernNavigationBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//   final String userRole;

//   const ModernNavigationBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//     required this.userRole,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final items = _getNavigationItems(userRole);
//     final width = MediaQuery.of(context).size.width;
//     final navHeight = width < 360 ? 70.0 : 80.0;
    
//     return Container(
//       height: navHeight,
//       decoration: BoxDecoration(
//         color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: isDarkMode 
//                 ? Colors.black.withValues(alpha: 0.3)
//                 : Colors.grey.withValues(alpha: 0.1),
//             blurRadius: width < 360 ? 8 : 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: width < 360 ? 12 : 16, 
//             vertical: width < 360 ? 6 : 8,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: items.asMap().entries.map((entry) {
//               final index = entry.key;
//               final item = entry.value;
//               final isSelected = index == currentIndex;
              
//               return _buildNavigationItem(
//                 context,
//                 item,
//                 isSelected,
//                 () => onTap(index),
//                 isDarkMode,
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavigationItem(
//     BuildContext context,
//     NavigationItem item,
//     bool isSelected,
//     VoidCallback onTap,
//     bool isDarkMode,
//   ) {
//     final width = MediaQuery.of(context).size.width;
//     final iconSize = width < 360 ? 20.0 : 24.0;
//     final fontSize = width < 360 ? 10.0 : 12.0;
//     final padding = width < 360 ? 12.0 : 16.0;
    
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: EdgeInsets.symmetric(horizontal: padding * 0.5, vertical: 8),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? const Color(0xFF00BCD4).withValues(alpha: 0.1)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(width < 360 ? 12 : 16),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 padding: EdgeInsets.all(width < 360 ? 6 : 8),
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? const Color(0xFF00BCD4)
//                       : Colors.transparent,
//                   borderRadius: BorderRadius.circular(width < 360 ? 10 : 12),
//                 ),
//                 child: Icon(
//                   item.icon,
//                   color: isSelected
//                       ? Colors.white
//                       : (isDarkMode ? Colors.white54 : Colors.grey[600]),
//                   size: iconSize,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 item.label,
//                 style: TextStyle(
//                   fontSize: fontSize,
//                   fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//                   color: isSelected
//                       ? const Color(0xFF00BCD4)
//                       : (isDarkMode ? Colors.white54 : Colors.grey[600]),
//                 ),
//                 textAlign: TextAlign.center,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   List<NavigationItem> _getNavigationItems(String role) {
//     // Handle both display names and API role values
//     String normalizedRole = role.toLowerCase();
    
//     if (normalizedRole.contains('admin')) {
//       return [
//         NavigationItem(
//           icon: Icons.dashboard_rounded,
//           label: 'Dashboard',
//         ),
//         NavigationItem(
//           icon: Icons.people_rounded,
//           label: 'Users',
//         ),
//         NavigationItem(
//           icon: Icons.leaderboard_rounded,
//           label: 'Leads',
//         ),
//         NavigationItem(
//           icon: Icons.analytics_rounded,
//           label: 'Analytics',
//         ),
//       ];
//     } else if (normalizedRole.contains('lead')) {
//       return [
//         NavigationItem(
//           icon: Icons.dashboard_rounded,
//           label: 'Dashboard',
//         ),
//         NavigationItem(
//           icon: Icons.add_circle_rounded,
//           label: 'Add Lead',
//         ),
//         NavigationItem(
//           icon: Icons.visibility_rounded,
//           label: 'View Leads',
//         ),
//         NavigationItem(
//           icon: Icons.analytics_rounded,
//           label: 'Reports',
//         ),
//       ];
//     } else if (normalizedRole.contains('ba') || normalizedRole.contains('specialist')) {
//       return [
//         NavigationItem(
//           icon: Icons.dashboard_rounded,
//           label: 'Dashboard',
//         ),
//         NavigationItem(
//           icon: Icons.app_registration_rounded,
//           label: 'Registered',
//         ),
//         NavigationItem(
//           icon: Icons.task_rounded,
//           label: 'Tasks',
//         ),
//         NavigationItem(
//           icon: Icons.person_rounded,
//           label: 'Profile',
//         ),
//       ];
//     } else {
//       return [
//         NavigationItem(
//           icon: Icons.dashboard_rounded,
//           label: 'Dashboard',
//         ),
//       ];
//     }
//   }
// }

// class NavigationItem {
//   final IconData icon;
//   final String label;

//   NavigationItem({
//     required this.icon,
//     required this.label,
//   });
// }

// class ModernBottomNavigation extends StatefulWidget {
//   final String userRole;
//   final Function(int) onPageChanged;

//   const ModernBottomNavigation({
//     super.key,
//     required this.userRole,
//     required this.onPageChanged,
//   });

//   @override
//   State<ModernBottomNavigation> createState() => _ModernBottomNavigationState();
// }

// class _ModernBottomNavigationState extends State<ModernBottomNavigation> {
//   int _currentIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return ModernNavigationBar(
//       currentIndex: _currentIndex,
//       userRole: widget.userRole,
//       onTap: (index) {
//         setState(() {
//           _currentIndex = index;
//         });
//         widget.onPageChanged(index);
//       },
//     );
//   }
// }

// // Floating Navigation Bar variant
// class FloatingNavigationBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//   final String userRole;

//   const FloatingNavigationBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//     required this.userRole,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     final items = _getNavigationItems(userRole);
//     final width = MediaQuery.of(context).size.width;
    
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: width < 360 ? 6 : 8, 
//         vertical: width < 360 ? 6 : 8,
//       ),
//       decoration: BoxDecoration(
//         color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: isDarkMode 
//                 ? Colors.black.withValues(alpha: 0.4)
//                 : Colors.grey.withValues(alpha: 0.2),
//             blurRadius: width < 360 ? 16 : 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: items.asMap().entries.map((entry) {
//           final index = entry.key;
//           final item = entry.value;
//           final isSelected = index == currentIndex;
          
//           return _buildFloatingNavItem(
//             context,
//             item,
//             isSelected,
//             () => onTap(index),
//             isDarkMode,
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildFloatingNavItem(
//     BuildContext context,
//     NavigationItem item,
//     bool isSelected,
//     VoidCallback onTap,
//     bool isDarkMode,
//   ) {
//     final width = MediaQuery.of(context).size.width;
//     final iconSize = width < 360 ? 20.0 : 24.0;
//     final fontSize = width < 360 ? 12.0 : 14.0;
    
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//           margin: EdgeInsets.symmetric(horizontal: 2),
//           padding: EdgeInsets.symmetric(
//             horizontal: 12,
//             vertical: 12,
//           ),
//           decoration: BoxDecoration(
//             color: isSelected
//                 ? const Color(0xFF00BCD4)
//                 : Colors.transparent,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: isSelected
//               ? Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       item.icon,
//                       color: Colors.white,
//                       size: iconSize,
//                     ),
//                     const SizedBox(width: 4),
//                     Flexible(
//                       child: Text(
//                         item.label,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: fontSize,
//                         ),
//                         overflow: TextOverflow.ellipsis,
//                         maxLines: 1,
//                       ),
//                     ),
//                   ],
//                 )
//               : Icon(
//                   item.icon,
//                   color: isDarkMode ? Colors.white54 : Colors.grey[600],
//                   size: iconSize,
//                 ),
//         ),
//       ),
//     );
//   }

//   List<NavigationItem> _getNavigationItems(String role) {
//     // Handle both display names and API role values
//     String normalizedRole = role.toLowerCase();
    
//     if (normalizedRole.contains('admin')) {
//       return [
//         NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
//         NavigationItem(icon: Icons.people_rounded, label: 'Users'),
//         NavigationItem(icon: Icons.leaderboard_rounded, label: 'Leads'),
//         NavigationItem(icon: Icons.analytics_rounded, label: 'Analytics'),
//       ];
//     } else if (normalizedRole.contains('lead')) {
//       return [
//         NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
//         NavigationItem(icon: Icons.add_circle_rounded, label: 'Add'),
//         NavigationItem(icon: Icons.visibility_rounded, label: 'View'),
//         NavigationItem(icon: Icons.analytics_rounded, label: 'Reports'),
//       ];
//     } else if (normalizedRole.contains('ba') || normalizedRole.contains('specialist')) {
//       return [
//         NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
//         NavigationItem(icon: Icons.app_registration_rounded, label: 'Leads'),
//         NavigationItem(icon: Icons.task_rounded, label: 'Tasks'),
//         NavigationItem(icon: Icons.person_rounded, label: 'Profile'),
//       ];
//     } else {
//       return [
//         NavigationItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
//       ];
//     }
//   }
// }