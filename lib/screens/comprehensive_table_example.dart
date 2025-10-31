import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/widgets/generic_table_view.dart';
import 'package:customer_maxx_crm/screens/dummy_data_example.dart';
import 'package:customer_maxx_crm/utils/data_converter.dart';

class ComprehensiveTableExample extends StatefulWidget {
  const ComprehensiveTableExample({super.key});

  @override
  State<ComprehensiveTableExample> createState() => _ComprehensiveTableExampleState();
}

class _ComprehensiveTableExampleState extends State<ComprehensiveTableExample> {
  // Sample JSON data (as provided in your example)
  final String jsonData = '''
  {
    "status": "success",
    "leads": [
        {
            "id": 101,
            "name": "Demo User 1",
            "phone": "9087654321",
            "email": "demouser1@gmail.co",
            "education": "MBA",
            "experience": "Fresher",
            "location": "Jalna",
            "status": "Not Connected",
            "feedback": null,
            "created_at": "2025-10-30 12:34:28",
            "discount": 0,
            "installment1": "0.00",
            "installment2": "0.00",
            "owner_name": "Manish Pandey",
            "assigned_name": "Radha Kumari",
            "latest_history": "30 Oct 2025 12:34 PM - Not Connected - New lead created"
        },
        {
            "id": 100,
            "name": "Aarav Patel",
            "phone": "+919876543210",
            "email": "aarav.patel@example.com",
            "education": "Master's in Business Administration",
            "experience": "7 years",
            "location": "Pune, India",
            "status": "Not Connected",
            "feedback": null,
            "created_at": "2025-10-30 11:47:49",
            "discount": 0,
            "installment1": "0.00",
            "installment2": "0.00",
            "owner_name": "Manish Pandey",
            "assigned_name": "Radha Kumari",
            "latest_history": "30 Oct 2025 11:47 AM - Not Connected - New lead created"
        },
        {
            "id": 99,
            "name": "Pratik Kumar",
            "phone": "8976543218",
            "email": "pk@gmail.com",
            "education": "BBA",
            "experience": "2 years",
            "location": "Dhule",
            "status": "",
            "feedback": "Demo attended successfully",
            "created_at": "2025-10-30 06:16:44",
            "discount": 5,
            "installment1": "1200.00",
            "installment2": "4500.00",
            "owner_name": "Manish Pandey",
            "assigned_name": "Radha Kumari",
            "latest_history": "30 Oct 2025 06:27 AM - Demo Scheduled"
        }
    ]
  }
  ''';

  List<DummyLead> leads = [];

  @override
  void initState() {
    super.initState();
    // Convert JSON data to DummyLead objects
    leads = DataConverter.jsonToDummyLeads(jsonData);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Comprehensive Table Example'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Full Data Table'),
              Tab(text: 'Selective Data Table'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Full Data Table
            _buildFullDataTable(),
            // Selective Data Table
            _buildSelectiveDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildFullDataTable() {
    return GenericTableView<DummyLead>(
      title: 'All Lead Data',
      data: leads,
      showSearch: true,
      showFilter: true,
      showExport: true,
      searchHint: 'Search leads...',
      columns: [
        GenericTableColumn(
          title: 'ID',
          value: (lead) => lead.id,
          width: 60,
        ),
        GenericTableColumn(
          title: 'Name',
          value: (lead) => lead.name,
          width: 150,
        ),
        GenericTableColumn(
          title: 'Contact',
          value: (lead) => '${lead.phone}\n${lead.email}',
          width: 200,
        ),
        GenericTableColumn(
          title: 'Education',
          value: (lead) => lead.education,
        ),
        GenericTableColumn(
          title: 'Experience',
          value: (lead) => lead.experience,
        ),
        GenericTableColumn(
          title: 'Location',
          value: (lead) => lead.location,
        ),
        GenericTableColumn(
          title: 'Status',
          value: (lead) => lead.status.isEmpty ? 'N/A' : lead.status,
          builder: (lead) {
            final status = lead.status.isEmpty ? 'N/A' : lead.status;
            Color statusColor = Colors.grey;
            
            if (status == 'Not Connected') {
              statusColor = Colors.orange;
            } else if (status == 'N/A') {
              statusColor = Colors.grey;
            }
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
        GenericTableColumn(
          title: 'Feedback',
          value: (lead) => lead.feedback,
        ),
        GenericTableColumn(
          title: 'Created',
          value: (lead) => lead.createdAt,
          width: 150,
        ),
        GenericTableColumn(
          title: 'Discount',
          value: (lead) => '${lead.discount}%',
        ),
        GenericTableColumn(
          title: 'Installments',
          value: (lead) => '\$${lead.installment1} / \$${lead.installment2}',
        ),
        GenericTableColumn(
          title: 'Owner',
          value: (lead) => lead.ownerName,
        ),
        GenericTableColumn(
          title: 'Assigned To',
          value: (lead) => lead.assignedName,
        ),
        GenericTableColumn(
          title: 'Latest History',
          value: (lead) => lead.latestHistory,
          width: 250,
        ),
      ],
      onRowTap: (lead) {
        _showLeadDetails(context, lead);
      },
      onRowEdit: (lead) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit ${lead.name}')),
        );
      },
      onRowDelete: (lead) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete ${lead.name}')),
        );
      },
    );
  }

  Widget _buildSelectiveDataTable() {
    return GenericTableView<DummyLead>(
      title: 'Selected Lead Data',
      data: leads,
      showSearch: true,
      showFilter: true,
      showExport: true,
      searchHint: 'Search by name or status...',
      columns: [
        GenericTableColumn(
          title: 'ID',
          value: (lead) => lead.id,
          width: 60,
        ),
        GenericTableColumn(
          title: 'Name',
          value: (lead) => lead.name,
          width: 150,
        ),
        GenericTableColumn(
          title: 'Status',
          value: (lead) => lead.status.isEmpty ? 'N/A' : lead.status,
          builder: (lead) {
            final status = lead.status.isEmpty ? 'N/A' : lead.status;
            Color statusColor = Colors.grey;
            
            if (status == 'Not Connected') {
              statusColor = Colors.orange;
            } else if (status == 'N/A') {
              statusColor = Colors.grey;
            }
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
        GenericTableColumn(
          title: 'Contact',
          value: (lead) => '${lead.phone}\n${lead.email}',
          width: 200,
        ),
        GenericTableColumn(
          title: 'Owner',
          value: (lead) => lead.ownerName,
        ),
      ],
      onRowTap: (lead) {
        _showLeadDetails(context, lead);
      },
    );
  }

  void _showLeadDetails(BuildContext context, DummyLead lead) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Lead Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('ID', lead.id.toString()),
              _buildDetailRow('Name', lead.name),
              _buildDetailRow('Phone', lead.phone),
              _buildDetailRow('Email', lead.email),
              _buildDetailRow('Education', lead.education),
              _buildDetailRow('Experience', lead.experience),
              _buildDetailRow('Location', lead.location),
              _buildDetailRow('Status', lead.status.isEmpty ? 'N/A' : lead.status),
              _buildDetailRow('Feedback', lead.feedback),
              _buildDetailRow('Created At', lead.createdAt),
              _buildDetailRow('Discount', '${lead.discount}%'),
              _buildDetailRow('Installment 1', '\$${lead.installment1}'),
              _buildDetailRow('Installment 2', '\$${lead.installment2}'),
              _buildDetailRow('Owner', lead.ownerName),
              _buildDetailRow('Assigned To', lead.assignedName),
              _buildDetailRow('Latest History', lead.latestHistory),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}