import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_maxx_crm/providers/auth_provider.dart';
import 'package:customer_maxx_crm/providers/leads_provider.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';
import 'package:customer_maxx_crm/widgets/custom_drawer.dart';
import 'package:table_calendar/table_calendar.dart';

class AllLeadsScreen extends StatefulWidget {
  const AllLeadsScreen({Key? key}) : super(key: key);

  @override
  State<AllLeadsScreen> createState() => _AllLeadsScreenState();
}

class _AllLeadsScreenState extends State<AllLeadsScreen> {
  late String _userName;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _feedbackController = TextEditingController();

  final List<String> _statuses = ['All', 'New', 'Follow Up', 'Closed'];

  @override
  void initState() {
    super.initState();
    // Get user name from auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _userName = authProvider.user?.name ?? 'Admin';
      });
    });
    
    // Load leads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
      leadsProvider.fetchAllLeads();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDate = selectedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'All Leads'),
      drawer: CustomDrawer(
        currentUserRole: 'Admin',
        currentUserName: _userName,
      ),
      body: Consumer<LeadsProvider>(
        builder: (context, leadsProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: 'Search by name or phone or email',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.search),
                            ),
                            onChanged: (value) {
                              // Implement search functionality
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Status',
                              border: OutlineInputBorder(),
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
                                // Filter leads by status
                                leadsProvider.fetchLeadsByStatus(value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TableCalendar(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2030, 12, 31),
                              focusedDay: _selectedDate,
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDate, day);
                              },
                              onDaySelected: _onDaySelected,
                              calendarFormat: CalendarFormat.month,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _feedbackController,
                            decoration: const InputDecoration(
                              hintText: 'Feedback filter',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Export CSV functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Export CSV'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Import CSV functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text('Import CSV'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (leadsProvider.isLoading)
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
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Lead Manager')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: leadsProvider.leads.map((lead) {
                        return DataRow(
                          cells: [
                            DataCell(Text(lead.id.toString())),
                            DataCell(Text(
                                '${lead.date.day}-${lead.date.month}-${lead.date.year}')),
                            DataCell(Text(lead.name)),
                            DataCell(Text(lead.phone)),
                            DataCell(Text(lead.email)),
                            DataCell(Text(lead.leadManager)),
                            DataCell(Text(lead.status)),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.visibility, color: Colors.blue),
                                onPressed: () {
                                  // View lead details functionality
                                },
                              ),
                            ),
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
    );
  }
}