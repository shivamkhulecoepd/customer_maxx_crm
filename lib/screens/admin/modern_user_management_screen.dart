import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/users/users_bloc.dart';
import 'package:customer_maxx_crm/blocs/users/users_event.dart';
import 'package:customer_maxx_crm/blocs/users/users_state.dart';
import 'package:customer_maxx_crm/widgets/modern_app_bar.dart';
import 'package:customer_maxx_crm/widgets/modern_drawer.dart';
import 'package:customer_maxx_crm/models/user.dart';

class ModernUserManagementScreen extends StatefulWidget {
  const ModernUserManagementScreen({super.key});

  @override
  State<ModernUserManagementScreen> createState() =>
      _ModernUserManagementScreenState();
}

class _ModernUserManagementScreenState
    extends State<ModernUserManagementScreen> {
  String _userName = '';
  String _userEmail = '';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _roles = ['Admin', 'Lead Manager', 'BA Specialist'];

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

    // Load users
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BlocProvider.of<UsersBloc>(context).add(LoadAllUsers());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddUserBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return AddUserBottomSheet(roles: _roles);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'User Management',
        userName: _userName,
        userEmail: _userEmail,
      ),
      drawer: ModernDrawer(
        currentUserRole: 'Admin',
        currentUserName: _userName,
        currentUserEmail: _userEmail,
      ),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, usersState) {
          return RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<UsersBloc>(context).add(LoadAllUsers());
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search and Add User Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF2E2E2E)
                                      : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search users...',
                                    prefixIcon: Icon(Icons.search),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    // Implement search functionality
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            FloatingActionButton(
                              backgroundColor: const Color(0xFF00BCD4),
                              onPressed: _showAddUserBottomSheet,
                              child: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Users List
                        const Text(
                          'All Users',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  if (usersState.isLoading)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final user = usersState.users[index];
                          return _buildUserCard(user, context);
                        },
                        childCount: usersState.users.length,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserCard(User user, BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      const Color(0xFF00BCD4).withValues(alpha: 0.1),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Color(0xFF00BCD4),
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
                        user.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF00BCD4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete User'),
                          content: Text(
                              'Are you sure you want to delete ${user.name}?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Delete user
                                BlocProvider.of<UsersBloc>(context)
                                    .add(DeleteUser(user.id));
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddUserBottomSheet extends StatefulWidget {
  final List<String> roles;

  const AddUserBottomSheet({super.key, required this.roles});

  @override
  State<AddUserBottomSheet> createState() => _AddUserBottomSheetState();
}

class _AddUserBottomSheetState extends State<AddUserBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Admin';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _addUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final newUser = User(
        id: 0, // Will be set by the backend
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _selectedRole,
        password: _passwordController.text,
      );

      // Add user through bloc
      BlocProvider.of<UsersBloc>(context).add(AddUser(newUser));

      // Close bottom sheet
      if (mounted) {
        Navigator.pop(context);
      }

      setState(() {
        _isLoading = false;
      });

      // Clear form
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Add New User',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an email';
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2E2E2E)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: widget.roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRole = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Add User',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}