import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';

import 'package:customer_maxx_crm/screens/admin/admin_dashboard.dart';
import 'package:customer_maxx_crm/screens/lead_manager/lead_manager_dashboard.dart';
import 'package:customer_maxx_crm/screens/ba_specialist/ba_specialist_dashboard.dart';

// Add logging import
import 'dart:developer' as developer;

enum AuthMode { login, register }

class ModernAuthScreen extends StatefulWidget {
  final AuthMode authMode;

  const ModernAuthScreen({super.key, required this.authMode});

  @override
  State<ModernAuthScreen> createState() => _ModernAuthScreenState();
}

class _ModernAuthScreenState extends State<ModernAuthScreen>
    with TickerProviderStateMixin {
  late AuthMode _currentMode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _selectedRole = 'Admin';

  // Error handling state
  String _errorMessage = '';
  bool _showError = false;
  bool _isSuccessMessage =
      false; // Flag to indicate if the message is a success message

  // Map display names to API role values
  final Map<String, String> _roleMap = {
    'Admin': 'admin',
    'Lead Manager': 'lead_manager',
    'BA Specialist': 'ba_specialist',
  };

  final List<String> _roles = ['Admin', 'Lead Manager', 'BA Specialist'];

  @override
  void initState() {
    super.initState();
    _currentMode = widget.authMode;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Add logging to see what state is being emitted
        developer.log(
          'AuthScreen received state: ${state.runtimeType}',
          name: 'AuthScreen',
        );

        if (state is AuthError) {
          // Log the technical error details
          developer.log(
            'Authentication error: ${state.message}',
            name: 'AuthScreen',
          );

          // Show the actual backend error message to the user
          setState(() {
            _errorMessage = state.message; // Display the actual backend message
            _showError = true;
            _isSuccessMessage =
                false; // Flag to indicate this is an error message
          });

          // Automatically hide the error after 5 seconds
          Future.delayed(const Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                _showError = false;
                _isSuccessMessage = false; // Reset the flag
              });
            }
          });
        } else if (state is AuthInitial && _currentMode == AuthMode.register) {
          // Show success message for registration
          developer.log(
            'Registration success: Switching to login mode',
            name: 'AuthScreen',
          );
          setState(() {
            _errorMessage = 'Registration successful! Please login.';
            _showError = true;
            _isSuccessMessage =
                true; // Flag to indicate this is a success message
            _currentMode = AuthMode.login;
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();
          });

          // Automatically hide the message after 3 seconds
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showError = false;
                _isSuccessMessage = false; // Reset the flag
              });
            }
          });
        } else if (state is Authenticated) {
          final userRole = state.user?.role;
          if (userRole != null) {
            Widget dashboard;
            switch (userRole) {
              case 'admin':
                dashboard = const ModernAdminDashboard();
                break;
              case 'lead_manager':
                dashboard = const ModernLeadManagerDashboard();
                break;
              case 'ba_specialist':
                dashboard = const ModernBASpecialistDashboard();
                break;
              default:
                // Handle case where role names don't match exactly
                if (userRole.toLowerCase().contains('admin')) {
                  dashboard = const ModernAdminDashboard();
                } else if (userRole.toLowerCase().contains('lead')) {
                  dashboard = const ModernLeadManagerDashboard();
                } else if (userRole.toLowerCase().contains('ba') ||
                    userRole.toLowerCase().contains('specialist')) {
                  dashboard = const ModernBASpecialistDashboard();
                } else {
                  return;
                }
            }
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => dashboard),
            );
          }
        } else if (state is Unauthenticated) {
          // Clear any error messages when user is unauthenticated (after logout)
          setState(() {
            _showError = false;
            _isSuccessMessage = false;
            _errorMessage = '';
          });
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDarkMode = themeState.isDarkMode;

          return Scaffold(
            backgroundColor: isDarkMode
                ? AppThemes.darkBackground
                : AppThemes.lightBackground,
            body: SafeArea(child: _buildMobileLayout(isDarkMode)),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(bool isDarkMode) {
    final width = MediaQuery.of(context).size.width;
    final padding = width < 360 ? 16.0 : 24.0;
    final topSpacing = width < 360 ? 20.0 : 40.0;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            SizedBox(height: topSpacing),
            _buildHeader(isDarkMode),
            SizedBox(height: width < 360 ? 24 : 40),
            _buildAuthForm(isDarkMode),
            SizedBox(height: width < 360 ? 20 : 30),
            _buildSwitchModeButton(isDarkMode),
            SizedBox(height: width < 360 ? 16 : 20),
            // _buildThemeToggle(isDarkMode),
            // SizedBox(height: width < 360 ? 16 : 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppThemes.getPrimaryGradient().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppThemes.getElevatedShadow(isDarkMode),
              ),
              // child: const Icon(
              //   Icons.business_center_rounded,
              //   color: Colors.white,
              //   size: 40,
              // ),
              child: Image.asset("assets/customermaxcrm1.png"),
            ),
            const SizedBox(height: 24),
            Text(
              'CustomerMax CRM',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentMode == AuthMode.login
                  ? 'Welcome back! Please sign in to continue'
                  : 'Create your account to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode
                    ? AppThemes.darkSecondaryText
                    : AppThemes.lightSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthForm(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? AppThemes.darkCardBackground : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppThemes.getCardShadow(isDarkMode),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentMode == AuthMode.login ? 'Sign In' : 'Sign Up',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
                ),
              ),
              const SizedBox(height: 24),

              // Error/SUCCESS message display
              if (_showError) ...[
                _buildMessageDisplay(
                  _errorMessage,
                  isDarkMode,
                  _isSuccessMessage,
                ),
                const SizedBox(height: 16),
              ],

              if (_currentMode == AuthMode.register) ...[
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                icon: Icons.lock_rounded,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                onTogglePassword: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Role Selection Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Role',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRole,
                    decoration: InputDecoration(
                      hintText: 'Select your role',
                      prefixIcon: const Icon(Icons.work_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppThemes.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    items: _roles.map((role) {
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

              if (_currentMode == AuthMode.register) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  icon: Icons.lock_rounded,
                  isPassword: true,
                  isPasswordVisible: _isConfirmPasswordVisible,
                  onTogglePassword: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
              ],

              if (_currentMode == AuthMode.login) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Handle forgot password
                    },
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppThemes.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final isLoading = authState is AuthLoading;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _currentMode == AuthMode.login
                                  ? 'Sign In'
                                  : 'Create Account',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !isPasswordVisible,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                    onPressed: onTogglePassword,
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppThemes.primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchModeButton(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _currentMode == AuthMode.login
              ? 'Don\'t have an account? '
              : 'Already have an account? ',
          style: TextStyle(
            color: isDarkMode
                ? AppThemes.darkSecondaryText
                : AppThemes.lightSecondaryText,
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _currentMode = _currentMode == AuthMode.login
                  ? AuthMode.register
                  : AuthMode.login;
            });
            _animationController.reset();
            _animationController.forward();
          },
          child: Text(
            _currentMode == AuthMode.login ? 'Sign Up' : 'Sign In',
            style: const TextStyle(
              color: AppThemes.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // New method to build user-friendly message display (both error and success)
  Widget _buildMessageDisplay(String message, bool isDarkMode, bool isSuccess) {
    // Determine colors based on message type
    final Color backgroundColor = isSuccess
        ? AppThemes.greenAccent.withValues(alpha: 0.1)
        : AppThemes.redAccent.withValues(alpha: 0.1);
    final Color borderColor = isSuccess
        ? AppThemes.greenAccent.withValues(alpha: 0.3)
        : AppThemes.redAccent.withValues(alpha: 0.3);
    final Color iconColor = isSuccess
        ? AppThemes.greenAccent
        : AppThemes.redAccent;
    final IconData icon = isSuccess
        ? Icons.check_circle_outline
        : Icons.error_outline;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDarkMode
                    ? AppThemes.darkPrimaryText
                    : AppThemes.lightPrimaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: iconColor, size: 20),
            onPressed: () {
              setState(() {
                _showError = false;
                _isSuccessMessage = false; // Reset the flag
              });
            },
          ),
        ],
      ),
    );
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      if (_currentMode == AuthMode.login) {
        // Handle login
        context.read<AuthBloc>().add(
          LoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _roleMap[_selectedRole], // Use mapped role value
          ),
        );
      } else {
        // Handle registration
        context.read<AuthBloc>().add(
          RegisterRequested(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _roleMap[_selectedRole], // Use mapped role value
          ),
        );
      }
    } catch (e) {
      // Log the exception
      developer.log(
        'Exception in _handleSubmit: $e',
        name: 'AuthScreen',
        error: e,
      );

      // Show user-friendly error message
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
        _showError = true;
        _isSuccessMessage = false; // Flag to indicate this is an error message
      });

      // Automatically hide the error after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showError = false;
            _isSuccessMessage = false; // Reset the flag
          });
        }
      });
    }
  }
}
