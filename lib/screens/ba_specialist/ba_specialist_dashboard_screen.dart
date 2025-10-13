import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_maxx_crm/providers/auth_provider.dart';
import 'package:customer_maxx_crm/providers/leads_provider.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';
import 'package:customer_maxx_crm/widgets/custom_drawer.dart';

class BASpecialistDashboardScreen extends StatefulWidget {
  const BASpecialistDashboardScreen({Key? key}) : super(key: key);

  @override
  State<BASpecialistDashboardScreen> createState() => _BASpecialistDashboardScreenState();
}

class _BASpecialistDashboardScreenState extends State<BASpecialistDashboardScreen> {
  late String _userName;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _locationController = TextEditingController();
  final _feedbackController = TextEditingController();
  String _selectedStatus = 'All';
  String _selectedOrderBy = 'Asc';
  String _selectedAssignedBy = 'Admin';

  final List<String> _statuses = ['All', 'New', 'Follow Up', 'Closed', 'Active'];
  final List<String> _orderOptions = ['Asc', 'Desc'];
  final List<String> _assignedByOptions = ['Admin', 'Lead Manager'];

  @override
  void initState() {
    super.initState();
    // Get user name from auth provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      setState(() {
        _userName = authProvider.user?.name ?? 'BA Specialist';
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
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    _locationController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
    
    leadsProvider.filterLeads(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      education: _educationController.text.trim(),
      experience: _experienceController.text.trim(),
      location: _locationController.text.trim(),
      status: _selectedStatus,
      feedback: _feedbackController.text.trim(),
      orderBy: _selectedOrderBy,
      assignedBy: _selectedAssignedBy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Welcome to BA Specialist Dashboard',
      ),
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
                  Text(
                    'Welcome, $_userName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Filter Leads',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Filter form
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _educationController,
                                decoration: const InputDecoration(
                                  labelText: 'Education',
                                  border: OutlineInputBorder(),
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
                                controller: _experienceController,
                                decoration: const InputDecoration(
                                  labelText: 'Experience',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _locationController,
                                decoration: const InputDecoration(
                                  labelText: 'Location',
                                  border: OutlineInputBorder(),
                                ),
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
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _feedbackController,
                                decoration: const InputDecoration(
                                  labelText: 'Feedback',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedOrderBy,
                                decoration: const InputDecoration(
                                  labelText: 'Order By',
                                  border: OutlineInputBorder(),
                                ),
                                items: _orderOptions.map((option) {
                                  return DropdownMenuItem(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedOrderBy = value;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedAssignedBy,
                                decoration: const InputDecoration(
                                  labelText: 'Assigned By',
                                  border: OutlineInputBorder(),
                                ),
                                items: _assignedByOptions.map((option) {
                                  return DropdownMenuItem(
                                    value: option,
                                    child: Text(option),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedAssignedBy = value;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _applyFilters,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Filter',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'My Leads',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (leadsProvider.isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Created At')),
                          DataColumn(label: Text('Lead Name')),
                          DataColumn(label: Text('Phone')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Education')),
                          DataColumn(label: Text('Experience')),
                          DataColumn(label: Text('Location')),
                          DataColumn(label: Text('Status')),
                          DataColumn(label: Text('Feedback')),
                          DataColumn(label: Text('Order By')),
                          DataColumn(label: Text('Assigned By')),
                        ],
                        rows: leadsProvider.leads.map((lead) {
                          return DataRow(
                            cells: [
                              DataCell(Text(
                                  '${lead.date.year}-${lead.date.month.toString().padLeft(2, '0')}-${lead.date.day.toString().padLeft(2, '0')}')),
                              DataCell(Text(lead.name)),
                              DataCell(Text(lead.phone)),
                              DataCell(Text(lead.email)),
                              DataCell(Text(lead.education)),
                              DataCell(Text(lead.experience)),
                              DataCell(Text(lead.location)),
                              DataCell(Text(lead.status)),
                              DataCell(Text(lead.feedback)),
                              DataCell(Text(lead.orderBy)),
                              DataCell(Text(lead.assignedBy)),
                            ],
                          );
                        }).toList(),
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