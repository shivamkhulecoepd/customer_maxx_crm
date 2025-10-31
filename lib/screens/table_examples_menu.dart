import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/screens/dummy_data_example.dart';
import 'package:customer_maxx_crm/screens/comprehensive_table_example.dart';
import 'package:customer_maxx_crm/screens/sample_generic_table_screen.dart';

class TableExamplesMenu extends StatelessWidget {
  const TableExamplesMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generic Table Examples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildExampleCard(
              context,
              title: 'Dummy Data Example',
              description: 'Shows how to use the generic table with your provided dummy data',
              icon: Icons.table_chart,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DummyDataExampleScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildExampleCard(
              context,
              title: 'Comprehensive Table Example',
              description: 'Demonstrates full and selective data display with tab navigation',
              icon: Icons.table_view,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComprehensiveTableExample(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildExampleCard(
              context,
              title: 'Multi-Type Table Example',
              description: 'Shows how to use the generic table with different data types (Products, Users, Orders)',
              icon: Icons.view_comfy,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SampleGenericTableScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'How to Use',
              content: 'The GenericTableView widget can display any type of data. '
                  'Just define your data model and specify which properties to show in columns.',
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Key Features',
              content: '• Works with any data type\n'
                  '• Customizable column rendering\n'
                  '• Built-in search functionality\n'
                  '• Responsive design\n'
                  '• Action buttons (edit/delete)\n'
                  '• Dark mode support',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
      child: ListTile(
        leading: Icon(icon, size: 36, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required String content}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 2,
      color: isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}