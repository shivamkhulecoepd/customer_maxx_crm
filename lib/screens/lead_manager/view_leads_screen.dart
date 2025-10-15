import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_event.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_state.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';
import 'package:customer_maxx_crm/widgets/modern_drawer.dart';
import 'package:intl/intl.dart';

class ViewLeadsScreen extends StatefulWidget {
  const ViewLeadsScreen({super.key});

  @override
  State<ViewLeadsScreen> createState() => _ViewLeadsScreenState();
}

class _ViewLeadsScreenState extends State<ViewLeadsScreen> {
  String _selectedStatus = '-- Filter by Status --';

  final List<String> _statuses = [
    '-- Filter by Status --',
    'Registered',
    'Demo Attended',
    'Not Connected',
    'Demo Interested',
    'Pending'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BlocProvider.of<LeadsBloc>(context).add(LoadAllLeads());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'View Leads'),
      drawer: const ModernDrawer(), // No parameters needed now
      body: BlocBuilder<LeadsBloc, LeadsState>(
        builder: (context, leadsState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.list, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'View Leads',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Filter Row
                Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _statuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                            });
                            if (value == '-- Filter by Status --') {
                              BlocProvider.of<LeadsBloc>(context).add(LoadAllLeads());
                            } else {
                              BlocProvider.of<LeadsBloc>(context).add(LoadLeadsByStatus(value));
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                if (leadsState.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFF2c5aa0)),
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        headingRowHeight: 50,
                        dataRowMinHeight: 50,
                        dataRowMaxHeight: 50,
                        columns: const [
                          DataColumn(
                            label: Text(
                              'ID',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Created At',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Lead Name',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Phone',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Education',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Experience',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Location',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Feedback',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Owner',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Assigned To',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'History',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Delete',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                        rows: leadsState.leads.map((lead) {
                          return DataRow(
                            cells: [
                              DataCell(Text(lead.id.toString())),
                              DataCell(Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(lead.date))),
                              DataCell(Text(lead.name)),
                              DataCell(Text(lead.phone)),
                              DataCell(Text(lead.email)),
                              DataCell(Text(lead.education)),
                              DataCell(Text(lead.experience)),
                              DataCell(Text(lead.location)),
                              DataCell(Text(lead.status)),
                              DataCell(Text(lead.feedback.isEmpty ? 'No feedback' : lead.feedback)),
                              DataCell(Text(lead.leadManager)),
                              DataCell(Text(lead.assignedBy.isNotEmpty ? lead.assignedBy : 'Nikita')),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    // View lead history functionality
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('View history for ${lead.name}')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  child: const Text('View', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () {
                                    _confirmDeleteLead(context, lead.id);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  ),
                                  child: const Text('Delete', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteLead(BuildContext context, int leadId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this lead?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                BlocProvider.of<LeadsBloc>(context).add(DeleteLead(leadId));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lead deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}