import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/widgets/generic_table_view.dart';

/// Example model for the dummy data you provided
class DummyLead {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String education;
  final String experience;
  final String location;
  final String status;
  final String feedback;
  final String createdAt;
  final int discount;
  final String installment1;
  final String installment2;
  final String ownerName;
  final String assignedName;
  final String latestHistory;

  DummyLead({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.education,
    required this.experience,
    required this.location,
    required this.status,
    required this.feedback,
    required this.createdAt,
    required this.discount,
    required this.installment1,
    required this.installment2,
    required this.ownerName,
    required this.assignedName,
    required this.latestHistory,
  });

  /// Factory method to create a DummyLead from JSON data
  factory DummyLead.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert dynamic values to int
    int? _toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }
    
    // Helper function to safely convert dynamic values to String for installments
    String? _toString(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      return value.toString();
    }
    
    return DummyLead(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      education: json['education'] as String,
      experience: json['experience'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      feedback: json['feedback'] as String? ?? '',
      createdAt: json['created_at'] as String,
      discount: _toInt(json['discount']) ?? 0,
      installment1: _toString(json['installment1']) ?? '0.00',
      installment2: _toString(json['installment2']) ?? '0.00',
      ownerName: json['owner_name'] as String,
      assignedName: json['assigned_name'] as String,
      latestHistory: json['latest_history'] as String,
    );
  }
}

class DummyDataExampleScreen extends StatelessWidget {
  const DummyDataExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data based on your dummy response
    final dummyLeads = [
      DummyLead(
        id: 101,
        name: "Demo User 1",
        phone: "9087654321",
        email: "demouser1@gmail.co",
        education: "MBA",
        experience: "Fresher",
        location: "Jalna",
        status: "Not Connected",
        feedback: "",
        createdAt: "2025-10-30 12:34:28",
        discount: 0,
        installment1: "0.00",
        installment2: "0.00",
        ownerName: "Manish Pandey",
        assignedName: "Radha Kumari",
        latestHistory: "30 Oct 2025 12:34 PM - Not Connected - New lead created"
      ),
      DummyLead(
        id: 100,
        name: "Aarav Patel",
        phone: "+919876543210",
        email: "aarav.patel@example.com",
        education: "Master's in Business Administration",
        experience: "7 years",
        location: "Pune, India",
        status: "Not Connected",
        feedback: "",
        createdAt: "2025-10-30 11:47:49",
        discount: 0,
        installment1: "0.00",
        installment2: "0.00",
        ownerName: "Manish Pandey",
        assignedName: "Radha Kumari",
        latestHistory: "30 Oct 2025 11:47 AM - Not Connected - New lead created"
      ),
      DummyLead(
        id: 99,
        name: "Pratik Kumar",
        phone: "8976543218",
        email: "pk@gmail.com",
        education: "BBA",
        experience: "2 years",
        location: "Dhule",
        status: "",
        feedback: "Demo attended successfully",
        createdAt: "2025-10-30 06:16:44",
        discount: 5,
        installment1: "1200.00",
        installment2: "4500.00",
        ownerName: "Manish Pandey",
        assignedName: "Radha Kumari",
        latestHistory: "30 Oct 2025 06:27 AM - Demo Scheduled"
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dummy Data Example'),
      ),
      body: GenericTableView<DummyLead>(
        title: 'Dummy Leads',
        data: dummyLeads,
        showSearch: true,
        showFilter: true,
        showExport: true,
        columns: [
          GenericTableColumn(
            title: 'ID',
            value: (lead) => lead.id,
            width: 60,
          ),
          GenericTableColumn(
            title: 'Name',
            value: (lead) => lead.name,
          ),
          GenericTableColumn(
            title: 'Phone',
            value: (lead) => lead.phone,
          ),
          GenericTableColumn(
            title: 'Email',
            value: (lead) => lead.email,
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
          ),
          GenericTableColumn(
            title: 'Feedback',
            value: (lead) => lead.feedback,
          ),
          GenericTableColumn(
            title: 'Created At',
            value: (lead) => lead.createdAt,
          ),
          GenericTableColumn(
            title: 'Discount',
            value: (lead) => '${lead.discount}%',
          ),
          GenericTableColumn(
            title: 'Installment 1',
            value: (lead) => '\$${lead.installment1}',
          ),
          GenericTableColumn(
            title: 'Installment 2',
            value: (lead) => '\$${lead.installment2}',
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
          ),
        ],
        onRowTap: (lead) {
          // Handle row tap
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped on ${lead.name}')),
          );
        },
        onRowEdit: (lead) {
          // Handle edit action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Edit ${lead.name}')),
          );
        },
        onRowDelete: (lead) {
          // Handle delete action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete ${lead.name}')),
          );
        },
      ),
    );
  }
}