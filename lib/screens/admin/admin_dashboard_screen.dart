import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_maxx_crm/providers/auth_provider.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';
import 'package:customer_maxx_crm/widgets/custom_drawer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    // Get user name from auth provider immediately
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userName = authProvider.user?.name ?? 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Admin Dashboard Panel'),
      drawer: CustomDrawer(
        currentUserRole: 'Admin',
        currentUserName: _userName,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Admin Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Stats cards
              GridView.count(
                crossAxisCount: 2, // number of items per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap:
                    true, // so it doesn't take infinite height inside Column/ScrollView
                physics:
                    const NeverScrollableScrollPhysics(), // disable internal scroll if inside parent scroll
                children: [
                  _buildStatCard('Total Users', '3', Theme.of(context).primaryColor),
                  _buildStatCard('Total Leads', '24', Colors.green),
                  _buildStatCard('Lead Managers', '3', Theme.of(context).primaryColor),
                  _buildStatCard('BA Specialists', '24', Colors.green),
                ],
              ),
              const SizedBox(height: 30),
              // Charts section
              const Text(
                'Analytics & Reports',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Bar chart
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  title: ChartTitle(text: 'Total Leads'),
                  series: _getBarSeries(),
                ),
              ),
              const SizedBox(height: 20),
              // Line chart
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  title: ChartTitle(text: 'Weekly Leads Overview'),
                  series: _getLineSeries(),
                ),
              ),
              const SizedBox(height: 20),
              // Pie chart
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SfCircularChart(
                  title: ChartTitle(text: 'Lead Status'),
                  legend: Legend(isVisible: true),
                  series: _getPieSeries(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to get bar chart data
  List<BarSeries<ChartData, String>> _getBarSeries() {
    final List<ChartData> chartData = [
      ChartData('Jan', 10),
      ChartData('Feb', 20),
      ChartData('Mar', 15),
      ChartData('Apr', 25),
      ChartData('May', 30),
    ];

    return [
      BarSeries<ChartData, String>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        name: 'Leads',
        color: Theme.of(context).primaryColor,
      ),
    ];
  }

  // Method to get line chart data
  List<LineSeries<ChartData, String>> _getLineSeries() {
    final List<ChartData> chartData = [
      ChartData('Mon', 5),
      ChartData('Tue', 10),
      ChartData('Wed', 8),
      ChartData('Thu', 12),
      ChartData('Fri', 15),
      ChartData('Sat', 7),
      ChartData('Sun', 9),
    ];

    return [
      LineSeries<ChartData, String>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        name: 'Leads',
        color: Theme.of(context).primaryColor,
      ),
    ];
  }

  // Method to get pie chart data
  List<PieSeries<ChartData, String>> _getPieSeries() {
    final List<ChartData> chartData = [
      ChartData('New', 12, color: Theme.of(context).primaryColor),
      ChartData('Follow Up', 8, color: Colors.orange),
      ChartData('Closed', 4, color: Colors.yellow),
    ];

    return [
      PieSeries<ChartData, String>(
        dataSource: chartData,
        xValueMapper: (ChartData data, _) => data.x,
        yValueMapper: (ChartData data, _) => data.y,
        pointColorMapper: (ChartData data, _) => data.color,
        name: 'Leads',
        dataLabelSettings: const DataLabelSettings(isVisible: true),
      ),
    ];
  }

  // Method to build stat cards
  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
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
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// Data model for charts
class ChartData {
  final String x;
  final double y;
  final Color? color;

  ChartData(this.x, this.y, {this.color});
}