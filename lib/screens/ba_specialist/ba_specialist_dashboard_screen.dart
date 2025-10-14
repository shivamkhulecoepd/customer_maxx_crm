import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_maxx_crm/providers/auth_provider.dart';
import 'package:customer_maxx_crm/providers/leads_provider.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';
import 'package:customer_maxx_crm/widgets/custom_drawer.dart';
import 'package:intl/intl.dart';

class BASpecialistDashboardScreen extends StatefulWidget {
  const BASpecialistDashboardScreen({Key? key}) : super(key: key);

  @override
  State<BASpecialistDashboardScreen> createState() => _BASpecialistDashboardScreenState();
}

class _BASpecialistDashboardScreenState extends State<BASpecialistDashboardScreen> {
  String _userName = '';
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _feedbackController = TextEditingController();
  String _selectedStatus = 'All Status';

  final List<String> _statuses = [
    'All Status',
    'Registered',
    'Demo Attended',
    'Not Connected',
    'Demo Interested',
    'Pending'
  ];

  @override
  void initState() {
    super.initState();
    // Get user name from auth provider immediately
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userName = authProvider.user?.name ?? 'shrikant';
    
    // Load leads data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
        leadsProvider.fetchAllLeads();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
        _dateController.text = DateFormat('dd-mm-yyyy').format(picked);
      });
    }
  }

  void _applyFilters() {
    final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
    
    if (_selectedStatus == 'All Status') {
      leadsProvider.fetchAllLeads();
    } else {
      leadsProvider.fetchLeadsByStatus(_selectedStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'BA Specialist Dashboard'),
      drawer: CustomDrawer(
        currentUserRole: 'BA Specialist',
        currentUserName: _userName,
      ),
      body: Consumer<LeadsProvider>(
        builder: (context, leadsProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  Text(
                    'Welcome to BA Specialist Dashboard $_userName 👋',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Filter Leads Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17a2b8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.filter_list, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              'Filter Leads',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Filter Row 1
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Lead Name',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  hintText: 'Phone',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _dateController,
                                decoration: const InputDecoration(
                                  hintText: 'dd-mm-yyyy',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                readOnly: true,
                                onTap: _selectDate,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
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
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _feedbackController,
                                decoration: const InputDecoration(
                                  hintText: 'Feedback',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: _applyFilters,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007bff),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Filter', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // My Leads Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17a2b8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.list, color: Colors.white),
                            const SizedBox(width: 8),
                            const Text(
                              'My Leads',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (leadsProvider.isLoading)
                          const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(const Color(0xFF2c5aa0)),
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              headingRowHeight: 50,
                              dataRowHeight: 50,
                              columns: const [
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
                              ],
                              rows: leadsProvider.leads.where((lead) => 
                                lead.assignedBy == _userName || lead.assignedBy == 'shrikant'
                              ).map((lead) {
                                return DataRow(
                                  color: WidgetStateProperty.all(Colors.white),
                                  cells: [
                                    DataCell(Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(lead.date))),
                                    DataCell(Text(lead.name)),
                                    DataCell(Text(lead.phone)),
                                    DataCell(Text(lead.email)),
                                    DataCell(Text(lead.education)),
                                    DataCell(Text(lead.experience)),
                                    DataCell(Text(lead.location)),
                                    DataCell(
                                      DropdownButton<String>(
                                        value: ['Not Connected', 'Registered', 'Demo Attended', 'Demo Interested', 'Pending'].contains(lead.status) ? lead.status : 'Not Connected',
                                        items: ['Not Connected', 'Registered', 'Demo Attended', 'Demo Interested', 'Pending'].map((status) {
                                          return DropdownMenuItem(
                                            value: status,
                                            child: Text(status, style: const TextStyle(fontSize: 12)),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          // Update lead status
                                        },
                                        underline: Container(),
                                      ),
                                    ),
                                    DataCell(Text(lead.feedback.isEmpty ? '-' : lead.feedback)),
                                    DataCell(Text(lead.leadManager)),
                                    DataCell(Text(lead.assignedBy.isNotEmpty ? lead.assignedBy : 'shrikant')),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}