import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:customer_maxx_crm/providers/auth_provider.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';
import 'package:customer_maxx_crm/widgets/custom_drawer.dart';

class LeadManagerDashboardScreen extends StatefulWidget {
  const LeadManagerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<LeadManagerDashboardScreen> createState() =>
      _LeadManagerDashboardScreenState();
}

class _LeadManagerDashboardScreenState
    extends State<LeadManagerDashboardScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    // Get user name from auth provider immediately
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userName = authProvider.user?.name ?? 'Lead Manager';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Welcome to Lead Manager Dashboard'),
      drawer: CustomDrawer(
        currentUserRole: 'Lead Manager',
        currentUserName: _userName,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $_userName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 30),
              // Stats cards in Grid
              GridView.count(
                crossAxisCount:
                    3, // Adjust based on screen size or use SliverGridDelegate for responsiveness
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard('Not Connected', '0', Colors.teal),
                  _buildStatCard('Follow-up Planned', '0', Colors.teal),
                  _buildStatCard('Follow-up Completed', '0', Colors.teal),
                  _buildStatCard('Demo Attended', '0', Colors.teal),
                  _buildStatCard('Warm Lead', '0', Colors.teal),
                  _buildStatCard('Hot Lead', '0', Colors.teal),
                  _buildStatCard('Converted', '0', Colors.teal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build stat cards
  Widget _buildStatCard(String title, String value, Color color) {
    // Get current time for timestamp
    String timestamp = DateFormat(
      'hh:mm a, MMMM dd, yyyy',
    ).format(DateTime.now());

    return Expanded(
      child: Container(
        height: 140, // Increased height for better layout
        padding: const EdgeInsets.all(12), // Added padding for spacing
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color], // Gradient effect
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12), // Slightly larger radius
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28, // Larger font for value
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8), // Added spacing between value and title
            Text(
              title,
              textAlign:
                  TextAlign.center, // Centered text for better readability
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500, // Medium weight for title
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4), // Added spacing for timestamp
            Text(
              'Updated: $timestamp', // Dynamic timestamp
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70, // Lighter color for timestamp
              ),
            ),
          ],
        ),
      ),
    );
  }
}
