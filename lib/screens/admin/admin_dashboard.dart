import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:customer_maxx_crm/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:customer_maxx_crm/utils/api_service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_event.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_state.dart';
import 'package:customer_maxx_crm/blocs/users/users_bloc.dart';
import 'package:customer_maxx_crm/blocs/users/users_event.dart';
import 'package:customer_maxx_crm/blocs/users/users_state.dart';
import 'package:customer_maxx_crm/blocs/dashboard/dashboard_bloc.dart';
import 'package:customer_maxx_crm/blocs/dashboard/dashboard_event.dart';
import 'package:customer_maxx_crm/blocs/dashboard/dashboard_state.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';
import 'package:customer_maxx_crm/widgets/navigation_bar.dart';

import 'package:customer_maxx_crm/widgets/generic_table_view.dart';
import 'package:customer_maxx_crm/models/user.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:customer_maxx_crm/models/dashboard_stats.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ModernAdminDashboard extends StatefulWidget {
  final int initialIndex;

  const ModernAdminDashboard({super.key, this.initialIndex = 0});

  @override
  State<ModernAdminDashboard> createState() => _ModernAdminDashboardState();
}

class _ModernAdminDashboardState extends State<ModernAdminDashboard> {
  late int _currentNavIndex;
  String _userName = '';
  String _userRole = '';

  final List<Widget>? actions = [];
  final bool showDrawer = true;
  bool _hasLoadedInitialUsersData = false;
  bool _hasLoadedInitialLeadsData = false;
  bool _hasLoadedInitialDashboardData = false;

  // Add User Form Controllers
  final _addUserFormKey = GlobalKey<FormState>();
  final _addUserNameController = TextEditingController();
  final _addUserEmailController = TextEditingController();
  final _addUserPasswordController = TextEditingController();
  String _selectedRole = '';
  bool _isEditingUser = false;
  User? _userToEdit;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialIndex;
    _loadUserData();
    // Load initial data
    _loadInitialData();
  }

  void _loadInitialData() {
    // Load all data on initialization
    context.read<LeadsBloc>().add(LoadAllLeads());
    context.read<UsersBloc>().add(LoadAllUsers());
    context.read<DashboardBloc>().add(LoadAdminStats());
  }

  @override
  void dispose() {
    _addUserNameController.dispose();
    _addUserEmailController.dispose();
    _addUserPasswordController.dispose();
    super.dispose();
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

  // Hardcoded roles as per requirements
  List<String> _getUserRoles() {
    return ['Admin', 'Lead Manager', 'BA Specialist'];
  }

  String _convertRoleToDatabaseFormat(String role) {
    // Handle empty or null roles
    if (role.isEmpty) {
      return 'admin'; // Default to admin
    }

    switch (role) {
      case 'Admin':
        return 'admin';
      case 'Lead Manager':
        return 'lead_manager';
      case 'BA Specialist':
        return 'ba_specialist';
      default:
        // Handle any other format by converting to lowercase with underscores
        return role.toLowerCase().replaceAll(' ', '_');
    }
  }

  String _convertRoleFromDatabaseFormat(String dbRole) {
    switch (dbRole) {
      case 'admin':
        return 'Admin';
      case 'lead_manager':
        return 'Lead Manager';
      case 'ba_specialist':
        return 'BA Specialist';
      default:
        // Handle other possible formats
        if (dbRole == 'LeadManager') return 'Lead Manager';
        if (dbRole == 'BASpecialist') return 'BA Specialist';
        return dbRole
            .split('_')
            .map(
              (word) => word.isEmpty
                  ? ''
                  : word[0].toUpperCase() + word.substring(1).toLowerCase(),
            )
            .join(' ');
    }
  }

  void _showAddUserForm() {
    // Clear form
    _addUserNameController.clear();
    _addUserEmailController.clear();
    _addUserPasswordController.clear();
    _selectedRole = 'Admin'; // Set default role
    _isEditingUser = false;
    _userToEdit = null;

    _showUserFormBottomSheet();
  }

  void _showEditUserForm(User user) {
    // Fill form with user data
    _addUserNameController.text = user.name;
    _addUserEmailController.text = user.email;
    _addUserPasswordController.clear(); // Don't prefill password
    _selectedRole = _convertRoleFromDatabaseFormat(user.role);
    _isEditingUser = true;
    _userToEdit = user;

    _showUserFormBottomSheet();
  }

  void _showUserFormBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddUserBottomSheet(),
    );
  }

  Future<void> _submitUserForm() async {
    if (_addUserFormKey.currentState!.validate()) {
      if (!ServiceLocator.isInitialized) return;

      try {
        final userService = ServiceLocator.userService;

        // Validate that we have a role selected
        final databaseRole = _convertRoleToDatabaseFormat(_selectedRole);
        if (databaseRole.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a valid role'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Create a user object with the form data
        final user = User(
          id: _isEditingUser && _userToEdit != null
              ? _userToEdit!.id
              : '0', // Will be assigned by the server
          name: _addUserNameController.text,
          email: _addUserEmailController.text,
          role: databaseRole,
          password: _addUserPasswordController.text.isNotEmpty
              ? _addUserPasswordController.text
              : null,
        );

        if (_isEditingUser && _userToEdit != null) {
          // Update existing user
          context.read<UsersBloc>().add(UpdateUser(user));
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // Add new user
          context.read<UsersBloc>().add(AddUser(user));
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User added successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to ${_isEditingUser ? 'update' : 'add'} user: $e',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _AddUserBottomSheet() {
    return Container(
      // height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _addUserFormKey,
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
              Text(
                _isEditingUser ? 'Edit User' : 'Add New User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildUserFormField(
                'Full Name',
                'Enter full name',
                Icons.person_rounded,
                _addUserNameController,
              ),
              const SizedBox(height: 16),
              _buildUserFormField(
                'Email',
                'Enter email address',
                Icons.email_rounded,
                _addUserEmailController,
              ),
              const SizedBox(height: 16),
              _buildUserFormField(
                'Password',
                _isEditingUser
                    ? 'Enter new password (optional)'
                    : 'Enter password',
                Icons.lock_rounded,
                _addUserPasswordController,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              _buildRoleDropdown(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitUserForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemes.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_isEditingUser ? 'Update User' : 'Add User'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserFormField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (label == 'Full Name' && (value == null || value.isEmpty)) {
                return 'Please enter a name';
              }
              if (label == 'Email' && (value == null || value.isEmpty)) {
                return 'Please enter an email';
              }
              if (label == 'Password' &&
                  !_isEditingUser &&
                  (value == null || value.isEmpty)) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Role',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _selectedRole.isEmpty ? 'Admin' : _selectedRole,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            hint: const Text('Select Role'),
            items: _getUserRoles().map((role) {
              return DropdownMenuItem(value: role, child: Text(role));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedRole = value;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a role';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LeadsBloc, LeadsState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppThemes.redAccent,
                ),
              );
            }
          },
        ),
        BlocListener<UsersBloc, UsersState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppThemes.redAccent,
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDarkMode = themeState.isDarkMode;

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
                setState(() {
                  _currentNavIndex = index;
                });
              },
            ),
            floatingActionButton: _buildFloatingActionButton(isDarkMode),
            body: _buildContentView(isDarkMode),
          );
        },
      ),
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
              "Admin Dashboard",
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

  Widget _buildContentView(bool isDarkMode) {
    switch (_currentNavIndex) {
      case 0:
        return _buildDashboardView(isDarkMode);
      case 1:
        return _buildUsersView(isDarkMode);
      case 2:
        return _buildLeadsView(isDarkMode);
      case 3:
        return _buildAnalyticsView(isDarkMode);
      default:
        return _buildDashboardView(isDarkMode);
    }
  }

  Widget _buildDashboardView(bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: () async {
        // Reset loading flags to ensure fresh data
        setState(() {
          _hasLoadedInitialUsersData = false;
          _hasLoadedInitialLeadsData = false;
          _hasLoadedInitialDashboardData = false;
        });
        
        // Load fresh data
        context.read<LeadsBloc>().add(LoadAllLeads());
        context.read<UsersBloc>().add(LoadAllUsers());
        context.read<DashboardBloc>().add(LoadAdminStats());
        
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
              _buildStatsGrid(isDarkMode),
              const SizedBox(height: 24),
              _buildPerformanceStats(isDarkMode),
              const SizedBox(height: 24),
              _buildQuickActions(isDarkMode),
              const SizedBox(height: 24),
              _buildMonthlyTrendsChart(isDarkMode),
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
              Icons.admin_panel_settings_rounded,
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
                  'Admin Dashboard - CustomerMax CRM',
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

  Widget _buildStatsGrid(bool isDarkMode) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, usersState) {
        return BlocBuilder<LeadsBloc, LeadsState>(
          builder: (context, leadsState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final crossAxisCount = screenWidth < 600 ? 2 : 4;

            // Show shimmer if either users or leads are loading
            if ((usersState.isLoading && usersState.users.isEmpty) ||
                (leadsState.isLoading && leadsState.leads.isEmpty)) {
              return _buildStatsGridShimmer(isDarkMode, crossAxisCount, screenWidth);
            }

            final totalUsers = usersState.users.length;
            final totalLeads = leadsState.leads.length;
            final activeLeads = leadsState.leads
                .where(
                  (lead) =>
                      lead.status.toLowerCase() != 'completed' &&
                      lead.status.toLowerCase() != 'rejected',
                )
                .length;
            final completedLeads = leadsState.leads
                .where((lead) => lead.status.toLowerCase() == 'completed')
                .length;
            final conversionRate = totalLeads > 0
                ? ((completedLeads / totalLeads) * 100).toStringAsFixed(1)
                : '0.0';

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
                final stats = [
                  {
                    'title': 'Total Users',
                    'value': totalUsers.toString(),
                    'icon': Icons.people_rounded,
                    'color': AppThemes.blueAccent,
                    'change': '+12%',
                  },
                  {
                    'title': 'Active Leads',
                    'value': activeLeads.toString(),
                    'icon': Icons.leaderboard_rounded,
                    'color': AppThemes.greenAccent,
                    'change': '+8%',
                  },
                  {
                    'title': 'Total Leads',
                    'value': totalLeads.toString(),
                    'icon': Icons.assignment_rounded,
                    'color': AppThemes.purpleAccent,
                    'change': '+15%',
                  },
                  {
                    'title': 'Conversion Rate',
                    'value': '$conversionRate%',
                    'icon': Icons.trending_up_rounded,
                    'color': AppThemes.orangeAccent,
                    'change': '+3%',
                  },
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
          },
        );
      },
    );
  }

  Widget _buildStatsGridShimmer(bool isDarkMode, int crossAxisCount, double screenWidth) {
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
        return _buildStatCardShimmer(isDarkMode, screenWidth);
      },
    );
  }

  Widget _buildStatCardShimmer(bool isDarkMode, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      constraints: BoxConstraints(
        minHeight: screenWidth * 0.3,
      ),
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
              Shimmer.fromColors(
                baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                child: Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
              ),
              Shimmer.fromColors(
                baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                child: Container(
                  width: screenWidth * 0.08,
                  height: screenWidth * 0.04,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                child: Container(
                  width: screenWidth * 0.15,
                  height: screenWidth * 0.07,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Shimmer.fromColors(
                baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
                child: Container(
                  width: screenWidth * 0.2,
                  height: screenWidth * 0.035,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
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
      constraints: BoxConstraints(
        minHeight: screenWidth * 0.3, // Minimum height constraint
      ),
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
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Distribute space evenly
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
            _buildActionCard('Add User', Icons.person_add_rounded, () {
              setState(() {
                _currentNavIndex = 1;
              });
            }, isDarkMode),
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            _buildActionCard('View Reports', Icons.analytics_rounded, () {
              setState(() {
                _currentNavIndex = 3;
              });
            }, isDarkMode),
            SizedBox(height: MediaQuery.of(context).size.width * 0.04),
            _buildActionCard('Manage Leads', Icons.leaderboard_rounded, () {
              setState(() {
                _currentNavIndex = 2;
              });
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
                Icons.person_add_rounded,
                'New user registered',
                'John Doe joined as Lead Manager',
                '2 hours ago',
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildActivityItem(
                Icons.leaderboard_rounded,
                'Lead status updated',
                'Lead #1234 status changed to Demo Attended',
                '5 hours ago',
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

  Widget _buildUsersView(bool isDarkMode) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, usersState) {
        // Load users data only when needed (first time)
        if (!_hasLoadedInitialUsersData &&
            usersState.users.isEmpty &&
            !usersState.isLoading &&
            usersState.error == null) {
          // Use addPostFrameCallback to avoid calling during build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<UsersBloc>().add(LoadAllUsers());
            setState(() {
              _hasLoadedInitialUsersData = true;
            });
          });
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Reset the flag and load fresh data
            setState(() {
              _hasLoadedInitialUsersData = false;
            });
            context.read<UsersBloc>().add(LoadAllUsers());
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: Builder(
            builder: (context) {
              if (usersState.isLoading && usersState.users.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (usersState.error != null && usersState.users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${usersState.error}'),
                      ElevatedButton(
                        onPressed: () {
                          context.read<UsersBloc>().add(LoadAllUsers());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final users = usersState.users;

              return GenericTableView<User>(
                title: 'User Management',
                data: users,
                columns: [
                  GenericTableColumn(
                    title: 'ID',
                    value: (user) => user.id,
                    width: 60,
                    builder: (user) =>
                        Text(user.id, overflow: TextOverflow.ellipsis),
                  ),
                  GenericTableColumn(
                    title: 'Name',
                    value: (user) => user.name,
                    width: 200,
                    builder: (user) =>
                        Text(user.name, overflow: TextOverflow.ellipsis),
                  ),
                  GenericTableColumn(
                    title: 'Email',
                    value: (user) => user.email,
                    width: 200, // Fixed width for email column
                  ),
                  GenericTableColumn(
                    title: 'Role',
                    value: (user) => _convertRoleFromDatabaseFormat(user.role),
                    width: 150, // Fixed width for role column
                    builder: (user) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemes.getStatusColor(
                          _convertRoleFromDatabaseFormat(user.role),
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _convertRoleFromDatabaseFormat(user.role),
                        style: TextStyle(
                          color: AppThemes.getStatusColor(
                            _convertRoleFromDatabaseFormat(user.role),
                          ),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onRowTap: (user) {
                  _showEditUserForm(user);
                },
                onRowEdit: (user) {
                  _showEditUserForm(user);
                },
                onRowDelete: (user) {
                  context.read<UsersBloc>().add(DeleteUser(user.id));
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLeadsView(bool isDarkMode) {
    return BlocBuilder<LeadsBloc, LeadsState>(
      builder: (context, leadsState) {
        // Load leads data only when needed (first time)
        if (!_hasLoadedInitialLeadsData &&
            leadsState.leads.isEmpty &&
            !leadsState.isLoading &&
            leadsState.error == null) {
          // Use addPostFrameCallback to avoid calling during build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<LeadsBloc>().add(LoadAllLeads());
            setState(() {
              _hasLoadedInitialLeadsData = true;
            });
          });
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Reset the flag and load fresh data
            setState(() {
              _hasLoadedInitialLeadsData = false;
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
                title: 'Leads Management',
                data: leads,
                columns: [
                  GenericTableColumn(
                    title: 'Lead ID',
                    value: (lead) => lead.id.toString(),
                    width: 100, // Fixed width for ID column
                  ),
                  GenericTableColumn(
                    title: 'Name',
                    value: (lead) => lead.name,
                    width: 200,
                  ),
                  GenericTableColumn(
                    title: 'Phone',
                    value: (lead) => lead.phone,
                    width: 150,
                  ),
                  GenericTableColumn(
                    title: 'Email',
                    value: (lead) => lead.email,
                    width: 200, // Fixed width for email column
                  ),
                  GenericTableColumn(
                    title: 'Lead Manager',
                    value: (lead) => lead.ownerName,
                    width: 150, // Fixed width for email column
                  ),
                  GenericTableColumn(
                    title: 'BA Specialist',
                    value: (lead) => lead.assignedName,
                    width: 150, // Fixed width for email column
                  ),
                  GenericTableColumn(
                    title: 'Status',
                    value: (lead) => lead.status,
                    width: 150, // Fixed width for status column
                    builder: (lead) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemes.getStatusColor(
                          lead.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lead.status,
                        style: TextStyle(
                          color: AppThemes.getStatusColor(lead.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  GenericTableColumn(
                    title: 'Feedback',
                    value: (lead) => lead.feedback,
                    width: 200, // Fixed width for email column
                  ),
                ],
                onRowTap: (lead) {
                  // Handle row tap
                },
                onRowDelete: (lead) {
                  context.read<LeadsBloc>().add(DeleteLead(lead.id));
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsView(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    return RefreshIndicator(
      onRefresh: () async {
        // Reset dashboard loading flag and load fresh data
        setState(() {
          _hasLoadedInitialDashboardData = false;
        });
        context.read<DashboardBloc>().add(LoadAdminStats());
        await Future.delayed(const Duration(milliseconds: 500));
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
                        "Analytics & Reports",
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
                      Icons.download_rounded,
                      'Export',
                      () => (),
                      isDarkMode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildAnalyticsStatsCards(isDarkMode),
              SizedBox(height: screenWidth * 0.04),
              _buildDetailedCharts(isDarkMode),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
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

  Widget _buildChartCard(String title, Widget chart, bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: 8),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: chart,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(),
      series: <CartesianSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: [
            ChartData('Jan', 35),
            ChartData('Feb', 28),
            ChartData('Mar', 34),
            ChartData('Apr', 32),
            ChartData('May', 40),
          ],
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          color: AppThemes.primaryColor,
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return SfCircularChart(
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: [
            ChartData('New', 30),
            ChartData('In Progress', 25),
            ChartData('Completed', 45),
          ],
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode) {
    return FloatingActionButton.extended(
      onPressed: () {
        _showAddUserForm();
      },
      backgroundColor: AppThemes.primaryColor,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Add User'),
    );
  }

  void _showQuickActionsBottomSheet() {
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
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person_add_rounded),
              title: const Text('Add User'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to add user screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard_rounded),
              title: const Text('Add Lead'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to add lead screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_rounded),
              title: const Text('Generate Report'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStats(bool isDarkMode) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        // Load dashboard data only when needed (first time)
        if (!_hasLoadedInitialDashboardData && state is DashboardInitial) {
          // Use addPostFrameCallback to avoid calling during build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<DashboardBloc>().add(LoadAdminStats());
              setState(() {
                _hasLoadedInitialDashboardData = true;
              });
            }
          });
        }

        if (state is DashboardLoading) {
          return _buildPerformanceStatsShimmer(isDarkMode);
        }

        if (state is DashboardError) {
          return _buildPerformanceStatsError(state.message, isDarkMode);
        }

        if (state is DashboardLoaded) {
          final stats = state.stats;
          return _buildPerformanceStatsContent(stats, isDarkMode);
        }

        return _buildPerformanceStatsShimmer(isDarkMode);
      },
    );
  }

  Widget _buildPerformanceStatsShimmer(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
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
            children: List.generate(6, (index) => Column(
              children: [
                _buildShimmerRow(isDarkMode),
                if (index < 5) const Divider(height: 1),
              ],
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerRow(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Shimmer.fromColors(
              baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
              highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Shimmer.fromColors(
            baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              width: 50,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStatsError(String message, bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
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
                Icon(
                  Icons.error_outline,
                  color: AppThemes.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading dashboard data',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    color: isDarkMode ? AppThemes.darkSecondaryText : AppThemes.lightSecondaryText,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<DashboardBloc>().add(LoadAdminStats());
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

  Widget _buildPerformanceStatsContent(AdminStats stats, bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 1 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Overview',
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
              _buildPerformanceRow(
                'Total Users (except Admins)',
                stats.users.total.toString(),
                Icons.people_rounded,
                AppThemes.blueAccent,
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildPerformanceRow(
                'Lead Managers',
                stats.users.leadManagers.toString(),
                Icons.supervisor_account_rounded,
                AppThemes.greenAccent,
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildPerformanceRow(
                'BA Specialists',
                stats.users.baSpecialists.toString(),
                Icons.support_agent_rounded,
                AppThemes.purpleAccent,
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildPerformanceRow(
                'Total Leads',
                stats.leads.total.toString(),
                Icons.leaderboard_rounded,
                AppThemes.orangeAccent,
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildPerformanceRow(
                'Registrations',
                stats.registrations.total.toString(),
                Icons.app_registration_rounded,
                AppThemes.redAccent,
                isDarkMode,
              ),
              const Divider(height: 1),
              _buildPerformanceRow(
                'Demos Conducted',
                stats.demos.total.toString(),
                Icons.video_call_rounded,
                AppThemes.primaryColor,
                isDarkMode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceRow(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.02,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: MediaQuery.of(context).size.width * 0.05,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyTrendsChart(bool isDarkMode) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          final stats = state.stats;
          return _buildMonthlyTrendsContent(stats, isDarkMode);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMonthlyTrendsContent(AdminStats stats, bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Prepare data for the chart
    final List<ChartData> sharedData = [];
    final List<ChartData> registeredData = [];

    for (int i = 0; i < stats.monthlyData.labels.length; i++) {
      sharedData.add(
        ChartData(
          stats.monthlyData.labels[i],
          stats.monthlyData.shared[i].toDouble(),
        ),
      );
      registeredData.add(
        ChartData(
          stats.monthlyData.labels[i],
          stats.monthlyData.registered[i].toDouble(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Trends',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
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
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelRotation: -45,
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelFormat: '{value}',
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              textStyle: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<ChartData, String>>[
              LineSeries<ChartData, String>(
                dataSource: sharedData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                name: 'Shared',
                color: AppThemes.primaryColor,
                markerSettings: const MarkerSettings(isVisible: true),
              ),
              LineSeries<ChartData, String>(
                dataSource: registeredData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                name: 'Registered',
                color: AppThemes.greenAccent,
                markerSettings: const MarkerSettings(isVisible: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsStatsCards(bool isDarkMode) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          final stats = state.stats;
          return _buildAnalyticsStatsContent(stats, isDarkMode);
        }
        return _buildAnalyticsStatsShimmer(isDarkMode);
      },
    );
  }

  Widget _buildAnalyticsStatsShimmer(bool isDarkMode) {
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
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildStatCardShimmer(isDarkMode, screenWidth);
      },
    );
  }

  Widget _buildDetailedChartsShimmer(bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCardShimmer('Leads Trend', isDarkMode, screenWidth),
        SizedBox(height: screenWidth * 0.04),
        _buildChartCardShimmer('User Distribution', isDarkMode, screenWidth),
        SizedBox(height: screenWidth * 0.04),
        _buildChartCardShimmer('Monthly Trends', isDarkMode, screenWidth),
      ],
    );
  }

  Widget _buildChartCardShimmer(String title, bool isDarkMode, double screenWidth) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01, vertical: 8),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 16),
          Shimmer.fromColors(
            baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsStatsContent(AdminStats stats, bool isDarkMode) {
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
      itemCount: 6,
      itemBuilder: (context, index) {
        final analyticsData = [
          {
            'title': 'Total Users',
            'value': stats.users.total.toString(),
            'icon': Icons.people_rounded,
            'color': AppThemes.blueAccent,
            'change':
                '+${stats.users.leadManagers + stats.users.baSpecialists > 0 ? ((stats.users.leadManagers + stats.users.baSpecialists) / stats.users.total * 100).toStringAsFixed(1) : "0"}%',
          },
          {
            'title': 'Total Leads',
            'value': stats.leads.total.toString(),
            'icon': Icons.leaderboard_rounded,
            'color': AppThemes.greenAccent,
            'change':
                '+${stats.leads.monthly > 0 ? ((stats.leads.monthly / (stats.leads.total > 0 ? stats.leads.total : 1)) * 100).toStringAsFixed(1) : "0"}%',
          },
          {
            'title': 'Registrations',
            'value': stats.registrations.total.toString(),
            'icon': Icons.app_registration_rounded,
            'color': AppThemes.purpleAccent,
            'change':
                '+${stats.registrations.monthly > 0 ? ((stats.registrations.monthly / (stats.registrations.total > 0 ? stats.registrations.total : 1)) * 100).toStringAsFixed(1) : "0"}%',
          },
          {
            'title': 'Demos',
            'value': stats.demos.total.toString(),
            'icon': Icons.video_call_rounded,
            'color': AppThemes.orangeAccent,
            'change':
                '+${stats.demos.monthly > 0 ? ((stats.demos.monthly / (stats.demos.total > 0 ? stats.demos.total : 1)) * 100).toStringAsFixed(1) : "0"}%',
          },
          {
            'title': 'Daily Leads',
            'value': stats.leads.daily.toString(),
            'icon': Icons.today_rounded,
            'color': AppThemes.primaryColor,
            'change': '+${stats.leads.daily > 0 ? "5.2" : "0"}%',
          },
          {
            'title': 'Monthly Growth',
            'value':
                '${stats.leads.monthly > 0 ? ((stats.leads.monthly / (stats.leads.total > 0 ? stats.leads.total : 1)) * 100).toStringAsFixed(1) : "0"}%',
            'icon': Icons.trending_up_rounded,
            'color': AppThemes.redAccent,
            'change': '+2.3%',
          },
        ];
        final data = analyticsData[index];
        return _buildStatCard(
          data['title'] as String,
          data['value'] as String,
          data['icon'] as IconData,
          data['color'] as Color,
          data['change'] as String,
          isDarkMode,
        );
      },
    );
  }

  Widget _buildDetailedCharts(bool isDarkMode) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded) {
          final stats = state.stats;
          return _buildDetailedChartsContent(stats, isDarkMode);
        }
        return _buildDetailedChartsShimmer(isDarkMode);
      },
    );
  }

  Widget _buildDetailedChartsContent(AdminStats stats, bool isDarkMode) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Prepare data for charts
    final List<ChartData> leadsData = [
      ChartData('Daily', stats.leads.daily.toDouble()),
      ChartData('Weekly', stats.leads.weekly.toDouble()),
      ChartData('Monthly', stats.leads.monthly.toDouble()),
    ];

    final List<ChartData> userData = [
      ChartData('Lead Managers', stats.users.leadManagers.toDouble()),
      ChartData('BA Specialists', stats.users.baSpecialists.toDouble()),
    ];

    // Prepare monthly data
    final List<ChartData> sharedData = [];
    final List<ChartData> registeredData = [];

    for (int i = 0; i < stats.monthlyData.labels.length; i++) {
      sharedData.add(
        ChartData(
          stats.monthlyData.labels[i],
          stats.monthlyData.shared[i].toDouble(),
        ),
      );
      registeredData.add(
        ChartData(
          stats.monthlyData.labels[i],
          stats.monthlyData.registered[i].toDouble(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
          ),
        ),
        const SizedBox(height: 16),
        // Leads trend chart
        _buildChartCard(
          'Leads Trend',
          SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelFormat: '{value}',
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              textStyle: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<ChartData, String>>[
              ColumnSeries<ChartData, String>(
                dataSource: leadsData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                name: 'Leads',
                color: AppThemes.primaryColor,
              ),
            ],
          ),
          isDarkMode,
        ),
        SizedBox(height: screenWidth * 0.04),
        // User distribution pie chart
        _buildChartCard(
          'User Distribution',
          SfCircularChart(
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              textStyle: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CircularSeries>[
              PieSeries<ChartData, String>(
                dataSource: userData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                explode: true,
                explodeIndex: 0,
              ),
            ],
          ),
          isDarkMode,
        ),
        SizedBox(height: screenWidth * 0.04),
        // Monthly trends line chart
        _buildChartCard(
          'Monthly Trends',
          SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelRotation: -45,
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelFormat: '{value}',
              labelStyle: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              textStyle: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<ChartData, String>>[
              LineSeries<ChartData, String>(
                dataSource: sharedData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                name: 'Shared',
                color: AppThemes.primaryColor,
                markerSettings: const MarkerSettings(isVisible: true),
              ),
              LineSeries<ChartData, String>(
                dataSource: registeredData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                name: 'Registered',
                color: AppThemes.greenAccent,
                markerSettings: const MarkerSettings(isVisible: true),
              ),
            ],
          ),
          isDarkMode,
        ),
      ],
    );
  }
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}
