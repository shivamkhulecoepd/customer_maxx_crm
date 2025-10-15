import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';

enum AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  final AuthMode authMode;

  const AuthScreen({super.key, this.authMode = AuthMode.login});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'Admin';
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  late AuthMode _authMode;

  final List<String> _roles = ['Admin', 'Lead Manager', 'BA Specialist'];

  @override
  void initState() {
    super.initState();
    _authMode = widget.authMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Use Bloc instead of Provider
      final authBloc = BlocProvider.of<AuthBloc>(context);
      authBloc.add(LoginRequested(
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRole,
      ));

      // We'll handle the response in the BlocListener
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Passwords do not match'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Use Bloc instead of Provider
      final authBloc = BlocProvider.of<AuthBloc>(context);
      authBloc.add(RegisterRequested(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRole,
      ));

      // We'll handle the response in the BlocListener
    }
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.register : AuthMode.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _authMode == AuthMode.login;
    
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        setState(() {
          _isLoading = false;
        });
        
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is Authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AuthInitial) {
          // Registration successful
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please login.'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _authMode = AuthMode.login;
          });
        }
      },
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final isDarkMode = themeState.isDarkMode;
          
          return Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDarkMode
                      ? [
                          const Color(0xFF0097A7),
                          const Color(0xFF00838F),
                          const Color(0xFF006064),
                        ]
                      : [
                          const Color(0xFF00BCD4),
                          const Color(0xFF00ACC1),
                          const Color(0xFF0097A7),
                        ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    
                    // Logo and App Name
                    Hero(
                      tag: 'app_logo',
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.business,
                              size: 40,
                              color: isDarkMode ? const Color(0xFF00BCD4) : const Color(0xFF00BCD4),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'CUSTOMER MAXX',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'C R M',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 4,
                              color: isDarkMode ? Colors.white70 : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // White Card Container that extends to bottom
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode 
                                  ? Colors.black.withValues(alpha: 0.3) 
                                  : Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: SingleChildScrollView(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Text(
                                    isLogin ? 'Login' : 'Register',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode 
                                          ? const Color(0xFFFFFFFF) 
                                          : const Color(0xFF263238),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isLogin ? 'Login to your account' : 'Create a new account',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode 
                                          ? const Color(0xFFBDBDBD) 
                                          : const Color(0xFF78909C),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  
                                  // Name Input (only for registration)
                                  if (!isLogin) ...[
                                    TextFormField(
                                      controller: _nameController,
                                      style: TextStyle(
                                        color: isDarkMode 
                                            ? const Color(0xFFFFFFFF) 
                                            : const Color(0xFF263238),
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Name',
                                        hintStyle: TextStyle(
                                          color: isDarkMode 
                                              ? const Color(0xFFBDBDBD) 
                                              : Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                        filled: true,
                                        fillColor: isDarkMode 
                                            ? const Color(0xFF2E2E2E) 
                                            : const Color(0xFFF5F5F5),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF00BCD4),
                                            width: 1.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 18,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.person_outline,
                                          color: isDarkMode 
                                              ? const Color(0xFFBDBDBD) 
                                              : const Color(0xFF546E7A),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                  
                                  // Email Input
                                  TextFormField(
                                    controller: _emailController,
                                    style: TextStyle(
                                      color: isDarkMode 
                                          ? const Color(0xFFFFFFFF) 
                                          : const Color(0xFF263238),
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Email',
                                      hintStyle: TextStyle(
                                        color: isDarkMode 
                                            ? const Color(0xFFBDBDBD) 
                                            : Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      filled: true,
                                      fillColor: isDarkMode 
                                          ? const Color(0xFF2E2E2E) 
                                          : const Color(0xFFF5F5F5),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF00BCD4),
                                          width: 1.5,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 1.5,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: isDarkMode 
                                            ? const Color(0xFFBDBDBD) 
                                            : const Color(0xFF546E7A),
                                      ),
                                    ),
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
                                  
                                  // Password Input
                                  TextFormField(
                                    controller: _passwordController,
                                    style: TextStyle(
                                      color: isDarkMode 
                                          ? const Color(0xFFFFFFFF) 
                                          : const Color(0xFF263238),
                                      fontSize: 14,
                                    ),
                                    obscureText: _obscurePassword,
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: TextStyle(
                                        color: isDarkMode 
                                            ? const Color(0xFFBDBDBD) 
                                            : Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      filled: true,
                                      fillColor: isDarkMode 
                                          ? const Color(0xFF2E2E2E) 
                                          : const Color(0xFFF5F5F5),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: isDarkMode 
                                              ? const Color(0xFFBDBDBD) 
                                              : Colors.grey[600],
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF00BCD4),
                                          width: 1.5,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 1.5,
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 18,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: isDarkMode 
                                            ? const Color(0xFFBDBDBD) 
                                            : const Color(0xFF546E7A),
                                      ),
                                    ),
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
                                  
                                  // Confirm Password Input (only for registration)
                                  if (!isLogin) ...[
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      style: TextStyle(
                                        color: isDarkMode 
                                            ? const Color(0xFFFFFFFF) 
                                            : const Color(0xFF263238),
                                        fontSize: 14,
                                      ),
                                      obscureText: _obscureConfirmPassword,
                                      decoration: InputDecoration(
                                        hintText: 'Confirm Password',
                                        hintStyle: TextStyle(
                                          color: isDarkMode 
                                              ? const Color(0xFFBDBDBD) 
                                              : Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                        filled: true,
                                        fillColor: isDarkMode 
                                            ? const Color(0xFF2E2E2E) 
                                            : const Color(0xFFF5F5F5),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: isDarkMode 
                                                ? const Color(0xFFBDBDBD) 
                                                : Colors.grey[600],
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword = !_obscureConfirmPassword;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF00BCD4),
                                            width: 1.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 18,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.lock_outline,
                                          color: isDarkMode 
                                              ? const Color(0xFFBDBDBD) 
                                              : const Color(0xFF546E7A),
                                        ),
                                      ),
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
                                    const SizedBox(height: 20),
                                  ] else ...[
                                    // Remember Me and Forgot Password (only for login)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Checkbox(
                                                value: _rememberMe,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _rememberMe = value ?? false;
                                                  });
                                                },
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                activeColor: const Color(0xFF00BCD4),
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Remember Me',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDarkMode 
                                                    ? const Color(0xFFBDBDBD) 
                                                    : const Color(0xFF546E7A),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // TODO: Implement forgot password
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(0, 0),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: Text(
                                            'Forgot Password?',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDarkMode 
                                                  ? const Color(0xFFE91E63) 
                                                  : const Color(0xFFE91E63),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                  
                                  // Role Selection Label
                                  Text(
                                    'Role',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode 
                                          ? const Color(0xFFBDBDBD) 
                                          : const Color(0xFF546E7A),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Role Dropdown
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDarkMode 
                                          ? const Color(0xFF2E2E2E) 
                                          : const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _selectedRole,
                                      style: TextStyle(
                                        color: isDarkMode 
                                            ? const Color(0xFFFFFFFF) 
                                            : const Color(0xFF263238),
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Color(0xFF00BCD4),
                                            width: 1.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 1.5,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 18,
                                        ),
                                        filled: true,
                                        fillColor: Colors.transparent,
                                      ),
                                      hint: Text(
                                        'Select Role',
                                        style: TextStyle(
                                          color: isDarkMode 
                                              ? const Color(0xFFBDBDBD) 
                                              : Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: isDarkMode 
                                            ? const Color(0xFFBDBDBD) 
                                            : Colors.grey[600],
                                      ),
                                      dropdownColor: isDarkMode 
                                          ? const Color(0xFF2E2E2E) 
                                          : Colors.white,
                                      items: _roles.map((role) {
                                        return DropdownMenuItem(
                                          value: role,
                                          child: Text(
                                            role,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode 
                                                  ? const Color(0xFFFFFFFF) 
                                                  : const Color(0xFF263238),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
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
                                  ),
                                  const SizedBox(height: 28),
                                  
                                  // Action Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : (isLogin ? _login : _register),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF00BCD4),
                                        foregroundColor: isDarkMode 
                                            ? const Color(0xFF121212) 
                                            : Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                        disabledBackgroundColor: const Color(0xFF00BCD4).withValues(alpha: 0.6),
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
                                          : Text(
                                              isLogin ? 'Sign In' : 'Register',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Switch Auth Mode Link
                                  Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          isLogin 
                                              ? 'Don\'t have an account?  ' 
                                              : 'Already have an account?  ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDarkMode 
                                                ? const Color(0xFFBDBDBD) 
                                                : const Color(0xFF546E7A),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: _switchAuthMode,
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(0, 0),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: Text(
                                            isLogin ? 'Create an Account' : 'Login',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: isDarkMode 
                                                  ? const Color(0xFFE91E63) 
                                                  : const Color(0xFFE91E63),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}