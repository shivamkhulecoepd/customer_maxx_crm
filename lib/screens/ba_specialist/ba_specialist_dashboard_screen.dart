import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_event.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_state.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';
import 'package:customer_maxx_crm/widgets/custom_drawer.dart';
import 'package:intl/intl.dart';

class BASpecialistDashboardScreen extends StatefulWidget {
  const BASpecialistDashboardScreen({super.key});

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
    // Get user name from auth bloc immediately
    final authState = BlocProvider.of<AuthBloc>(context).state;
    if (authState is Authenticated && authState.user != null) {
      _userName = authState.user!.name;
    } else {
      _userName = 'shrikant';
    }
    
    // Load leads data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BlocProvider.of<LeadsBloc>(context).add(LoadAllLeads());
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
    if (_selectedStatus == 'All Status') {
      BlocProvider.of<LeadsBloc>(context).add(LoadAllLeads());
    } else {
      BlocProvider.of<LeadsBloc>(context).add(LoadLeadsByStatus(_selectedStatus));
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
      body: BlocBuilder<LeadsBloc, LeadsState>(
        builder: (context, leadsState) {
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
                                initialValue: _selectedStatus,
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
                        
                        if (leadsState.isLoading)
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
                              dataRowMinHeight: 50,
                              dataRowMaxHeight: 50,
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
                              rows: leadsState.leads.where((lead) => 
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
                                          if (value != null) {
                                            final updatedLead = Lead(
                                              id: lead.id,
                                              date: lead.date,
                                              name: lead.name,
                                              phone: lead.phone,
                                              email: lead.email,
                                              leadManager: lead.leadManager,
                                              status: value,
                                              feedback: lead.feedback,
                                              education: lead.education,
                                              experience: lead.experience,
                                              location: lead.location,
                                              orderBy: lead.orderBy,
                                              assignedBy: lead.assignedBy,
                                              discount: lead.discount,
                                              firstInstallment: lead.firstInstallment,
                                              secondInstallment: lead.secondInstallment,
                                              finalFee: lead.finalFee,
                                              baSpecialist: lead.baSpecialist,
                                            );
                                            BlocProvider.of<LeadsBloc>(context).add(UpdateLead(updatedLead));
                                          }
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