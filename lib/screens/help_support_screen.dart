import 'package:customer_maxx_crm/blocs/theme/theme_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/widgets/main_layout.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String _userName = '';
  String _userEmail = '';

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
            // leading: null,
            automaticallyImplyLeading: false,
            title: _buildCustomAppBar(context, isDarkMode),
            centerTitle: true,
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
          ),
          body: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              final isDarkMode = themeState.isDarkMode;

              return RefreshIndicator(
                onRefresh: () async {
                  // Refresh help content
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
                                Icons.help_outline,
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'How can we help you?',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Find answers to common questions or contact our support team',
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

                        // Help Categories
                        const Text(
                          'Help Categories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildHelpCategoryCard(
                          context,
                          isDarkMode,
                          Icons.account_circle_outlined,
                          'Account & Profile',
                          'Manage your account settings, profile information, and preferences',
                          () {
                            // Navigate to account help
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildHelpCategoryCard(
                          context,
                          isDarkMode,
                          Icons.leaderboard_outlined,
                          'Leads Management',
                          'Learn how to add, edit, and track leads in the system',
                          () {
                            // Navigate to leads help
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildHelpCategoryCard(
                          context,
                          isDarkMode,
                          Icons.settings_outlined,
                          'Settings & Preferences',
                          'Customize your experience with app settings and preferences',
                          () {
                            // Navigate to settings help
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildHelpCategoryCard(
                          context,
                          isDarkMode,
                          Icons.security_outlined,
                          'Security & Privacy',
                          'Understand our security measures and privacy policies',
                          () {
                            // Navigate to security help
                          },
                        ),

                        const SizedBox(height: 32),

                        // Contact Support
                        const Text(
                          'Contact Support',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildContactCard(
                          context,
                          isDarkMode,
                          Icons.email_outlined,
                          'Email Support',
                          'support@customermaxx.com',
                          'Response within 24 hours',
                          () {
                            // Open email client
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildContactCard(
                          context,
                          isDarkMode,
                          Icons.phone_outlined,
                          'Phone Support',
                          '+1 (555) 123-4567',
                          'Mon-Fri, 9AM-5PM EST',
                          () {
                            // Make phone call
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildContactCard(
                          context,
                          isDarkMode,
                          Icons.chat_outlined,
                          'Live Chat',
                          'Chat with our support team',
                          'Available now',
                          () {
                            // Open live chat
                          },
                        ),

                        const SizedBox(height: 32),

                        // FAQ Section
                        const Text(
                          'Frequently Asked Questions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildFAQItem(
                          context,
                          isDarkMode,
                          'How do I reset my password?',
                          'You can reset your password by going to Settings > Security > Change Password. If you\'re locked out, contact support for assistance.',
                        ),

                        const SizedBox(height: 8),

                        _buildFAQItem(
                          context,
                          isDarkMode,
                          'How do I add a new lead?',
                          'Navigate to the Leads section and click the "Add Lead" button. Fill in the required information and save the lead to your pipeline.',
                        ),

                        const SizedBox(height: 8),

                        _buildFAQItem(
                          context,
                          isDarkMode,
                          'Can I export lead data?',
                          'Yes, you can export lead data from the Leads Management section. Click the export button and choose your preferred format (CSV, Excel).',
                        ),

                        const SizedBox(height: 8),

                        _buildFAQItem(
                          context,
                          isDarkMode,
                          'How do I change my notification preferences?',
                          'Go to Settings > Notifications to customize which notifications you receive and how you receive them (email, push, etc.).',
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCustomAppBar(BuildContext context, bool isDarkMode) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: Row(
        children: [
          _buildIconButton(
            context,
            Icons.arrow_back_ios_rounded,
            () => Navigator.of(context).pop(),
            isDarkMode,
          ),

          SizedBox(width: width < 360 ? 8 : 12),

          // Title
          Expanded(
            child: Text(
              'Help & Support',
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

  Widget _buildHelpCategoryCard(
    BuildContext context,
    bool isDarkMode,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppThemes.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppThemes.primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? AppThemes.darkSecondaryText
                            : AppThemes.lightSecondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDarkMode
                    ? AppThemes.darkSecondaryText
                    : AppThemes.lightSecondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    bool isDarkMode,
    IconData icon,
    String title,
    String contactInfo,
    String availability,
    VoidCallback onTap,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppThemes.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppThemes.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contactInfo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                availability,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode
                      ? AppThemes.darkSecondaryText
                      : AppThemes.lightSecondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context,
    bool isDarkMode,
    String question,
    String answer,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppThemes.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.question_mark,
                  color: AppThemes.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode
                      ? AppThemes.darkSecondaryText
                      : AppThemes.lightSecondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
