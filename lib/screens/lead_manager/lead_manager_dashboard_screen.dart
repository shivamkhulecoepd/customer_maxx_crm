import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_maxx_crm/providers/auth_provider.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';
import 'package:customer_maxx_crm/widgets/custom_drawer.dart';

class LeadManagerDashboardScreen extends StatefulWidget {
  const LeadManagerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<LeadManagerDashboardScreen> createState() => _LeadManagerDashboardScreenState();
}

class _LeadManagerDashboardScreenState extends State<LeadManagerDashboardScreen> {
  late String _userName;

  @override
  void initState() {
    super.initState();
    // Get user name from auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _userName = authProvider.user?.name ?? 'Lead Manager';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Welcome to Lead Manager Dashboard',
      ),
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
              // Stats cards
              Row(
                children: [
                  _buildStatCard('Total Leads', '10', Colors.blue),
                  const SizedBox(width: 16),
                  _buildStatCard('New Leads', '5', Colors.green),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatCard('Follow Up', '3', Colors.orange),
                  const SizedBox(width: 16),
                  _buildStatCard('Closed', '2', Colors.red),
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
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
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
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}