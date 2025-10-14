import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_maxx_crm/providers/auth_provider.dart';
import 'package:customer_maxx_crm/providers/leads_provider.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';
import 'package:customer_maxx_crm/widgets/custom_drawer.dart';
import 'package:intl/intl.dart';


class AllLeadsScreen extends StatefulWidget {
  const AllLeadsScreen({Key? key}) : super(key: key);

  @override
  State<AllLeadsScreen> createState() => _AllLeadsScreenState();
}

class _AllLeadsScreenState extends State<AllLeadsScreen> {
  String _userName = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = '-- Filter by Status --';
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  bool _selectAll = false;
  final Set<int> _selectedLeads = {};

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
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        setState(() {
          _userName = authProvider.user?.name ?? 'Admin';
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
        leadsProvider.fetchAllLeads();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
        return Colors.green;
      case 'demo attended':
        return Colors.blue;
      case 'not connected':
        return Colors.orange;
      case 'demo interested':
        return Colors.purple;
      case 'pending':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'All Leads'),
      drawer: CustomDrawer(
        currentUserRole: 'Admin',
        currentUserName: _userName,
      ),
      body: SingleChildScrollView(
        child: Consumer<LeadsProvider>(
          builder: (context, leadsProvider, child) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'All Leads',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'List of all leads in the system.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Action Buttons Row
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              bool success = await leadsProvider.exportCSV();
                              if (mounted) {
                                if (success) {
                                  _showSnackBar('CSV exported successfully');
                                } else {
                                  _showSnackBar('Error exporting CSV');
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                _showSnackBar('Error exporting CSV: $e');
                              }
                            }
                          },
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text('Export Leads', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF17a2b8),
                          ),
                        ),
                        const Spacer(),
                        // File picker for import
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: const Text('Choose file'),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                color: Colors.grey[200],
                                child: const Text('No file chosen'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              bool success = await leadsProvider.importCSV();
                              if (mounted) {
                                if (success) {
                                  _showSnackBar('CSV imported successfully');
                                } else {
                                  _showSnackBar('Error importing CSV');
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                _showSnackBar('Error importing CSV: $e');
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF17a2b8),
                          ),
                          child: const Text('Import CSV', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Filters Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search by Name, Phone, Email',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (value) {
                              leadsProvider.searchLeads(value);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatus,
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
                                  leadsProvider.fetchAllLeads();
                                } else {
                                  leadsProvider.fetchLeadsByStatus(value);
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                              hintText: 'dd-mm-yyyy',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            readOnly: true,
                            onTap: _selectDate,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _feedbackController,
                            decoration: const InputDecoration(
                              hintText: 'Filter by Feedback',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (value) {
                              leadsProvider.searchLeads(_searchController.text);
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            leadsProvider.fetchAllLeads();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF17a2b8),
                          ),
                          child: const Text('Apply', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Delete Selected Button
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _selectedLeads.isEmpty
                              ? null
                              : () async {
                                  try {
                                    bool success = await leadsProvider
                                        .deleteSelected(_selectedLeads.toList());
                                    if (mounted) {
                                      if (success) {
                                        setState(() {
                                          _selectedLeads.clear();
                                          _selectAll = false;
                                        });
                                        _showSnackBar('Selected leads deleted');
                                      } else {
                                        _showSnackBar('Error deleting leads');
                                      }
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      _showSnackBar('Error deleting leads: $e');
                                    }
                                  }
                                },
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: const Text('Delete Selected', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Leads Table Section
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Loading Indicator
                            if (leadsProvider.isLoading)
                              const Center(child: CircularProgressIndicator())
                            else if (leadsProvider.leads.isEmpty)
                              const Center(
                                child: Text(
                                  'No leads found',
                                  style: TextStyle(fontSize: 18),
                                ),
                              )
                            else
                              // Responsive DataTable
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: constraints.maxWidth,
                                  ),
                                  child: DataTable(
                                    showCheckboxColumn: false,
                                    headingRowColor:
                                        WidgetStateProperty.all(const Color(0xFF2c5aa0)),
                                    headingTextStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    headingRowHeight: 50,
                                    dataRowHeight: 50,
                                    columns: const [
                                      DataColumn(
                                        label: Checkbox(
                                          value: false,
                                          onChanged: null,
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Sr.\nNo.',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Date',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Name',
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
                                          'Lead Manager',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'BA Specialist',
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
                                    ],
                                    rows: leadsProvider.leads.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      var lead = entry.value;
                                      final isSelected = _selectedLeads.contains(lead.id);

                                      return DataRow(
                                        color: WidgetStateProperty.resolveWith<Color?>(
                                            (Set<WidgetState> states) {
                                          if (states.contains(WidgetState.selected)) {
                                            return Colors.blue.withOpacity(0.2);
                                          }
                                          if (isSelected) {
                                            return Colors.blue.withOpacity(0.1);
                                          }
                                          return index.isEven
                                              ? Colors.grey.withOpacity(0.1)
                                              : null;
                                        }),
                                        cells: [
                                          DataCell(
                                            Checkbox(
                                              value: isSelected,
                                              onChanged: (value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedLeads.add(lead.id);
                                                  } else {
                                                    _selectedLeads.remove(lead.id);
                                                  }
                                                  _selectAll = _selectedLeads.length ==
                                                      leadsProvider.leads.length;
                                                });
                                              },
                                            ),
                                          ),
                                          DataCell(Text((index + 1).toString())),
                                          DataCell(Text(
                                              '${DateFormat('dd MMM yyyy').format(lead.date)} ${DateFormat('HH:mm').format(lead.date)}\nAM')),
                                          DataCell(Text(
                                            lead.name,
                                            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                          )),
                                          DataCell(Text(lead.phone)),
                                          DataCell(Text(lead.email)),
                                          DataCell(Text(lead.leadManager)),
                                          DataCell(Text(lead.assignedBy.isNotEmpty ? lead.assignedBy : 'Nikita')),
                                          DataCell(
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(lead.status),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                lead.status,
                                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                              ),
                                            ),
                                          ),
                                          DataCell(Text(lead.feedback.isEmpty ? '-' : lead.feedback)),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}