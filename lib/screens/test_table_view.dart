import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/widgets/generic_table_view.dart';
import 'package:customer_maxx_crm/models/lead.dart';

class TestTableView extends StatelessWidget {
  const TestTableView({super.key});

  @override
  Widget build(BuildContext context) {
    // Create some test data
    final testLeads = [
      Lead(
        id: 1,
        name: 'Test Lead 1',
        phone: '1234567890',
        email: 'test1@example.com',
        education: 'MBA',
        experience: '5 years',
        location: 'New York',
        status: 'Pending',
        feedback: 'Initial feedback',
        createdAt: '2023-01-01 10:00:00',
        ownerName: 'Owner 1',
        assignedName: 'Assigned 1',
        latestHistory: 'History 1',
        discount: 10,
        installment1: 100.0,
        installment2: 200.0,
      ),
      Lead(
        id: 2,
        name: 'Test Lead 2',
        phone: '0987654321',
        email: 'test2@example.com',
        education: 'BBA',
        experience: '3 years',
        location: 'California',
        status: 'Completed',
        feedback: 'Final feedback',
        createdAt: '2023-01-02 11:00:00',
        ownerName: 'Owner 2',
        assignedName: 'Assigned 2',
        latestHistory: 'History 2',
        discount: 5,
        installment1: 150.0,
        installment2: 250.0,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Table View'),
      ),
      body: GenericTableView<Lead>(
        title: 'Test Leads',
        data: testLeads,
        columns: [
          GenericTableColumn<Lead>(
            title: 'ID',
            value: (lead) => lead.id.toString(),
            width: 60,
          ),
          GenericTableColumn<Lead>(
            title: 'Name',
            value: (lead) => lead.name,
          ),
          GenericTableColumn<Lead>(
            title: 'Email',
            value: (lead) => lead.email,
          ),
          GenericTableColumn<Lead>(
            title: 'Status',
            value: (lead) => lead.status,
          ),
        ],
        onRowTap: (lead) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on ${lead.name}')),
          );
        },
      ),
    );
  }
}