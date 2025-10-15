import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_event.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';
import 'package:customer_maxx_crm/widgets/custom_drawer.dart';

class AddLeadScreen extends StatefulWidget {
  const AddLeadScreen({super.key});

  @override
  State<AddLeadScreen> createState() => _AddLeadScreenState();
}

class _AddLeadScreenState extends State<AddLeadScreen> {
  String _userName = '';
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedLeadManager = '-- Select Lead Manager --';
  String _selectedBASpecialist = '-- Select Specialist --';

  final List<String> _leadManagers = [
    '-- Select Lead Manager --',
    'achal',
    'D V P Sridhar',
    'gayatri'
  ];

  final List<String> _baSpecialists = [
    '-- Select Specialist --',
    'Nikita',
    'shrikant'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authState = BlocProvider.of<AuthBloc>(context).state;
        if (authState is Authenticated && authState.user != null) {
          setState(() {
            _userName = authState.user!.name;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _submitLead() async {
    if (_formKey.currentState!.validate()) {
      final newLead = Lead(
        id: 0, // Will be assigned by service
        date: DateTime.now(),
        name: _nameController.text.trim(),
        phone: _contactController.text.trim(),
        email: _emailController.text.trim(),
        leadManager: _selectedLeadManager == '-- Select Lead Manager --' ? '' : _selectedLeadManager,
        status: 'New',
        feedback: '',
        education: _educationController.text.trim(),
        experience: _experienceController.text.trim(),
        location: _locationController.text.trim(),
        orderBy: '',
        assignedBy: _selectedBASpecialist == '-- Select Specialist --' ? '' : _selectedBASpecialist,
        discount: null,
        firstInstallment: null,
        secondInstallment: null,
        finalFee: null,
        baSpecialist: _selectedBASpecialist == '-- Select Specialist --' ? '' : _selectedBASpecialist,
      );

      BlocProvider.of<LeadsBloc>(context).add(AddLead(newLead));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lead added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Clear form
      _formKey.currentState!.reset();
      _nameController.clear();
      _contactController.clear();
      _emailController.clear();
      _educationController.clear();
      _experienceController.clear();
      _locationController.clear();
      setState(() {
        _selectedLeadManager = '-- Select Lead Manager --';
        _selectedBASpecialist = '-- Select Specialist --';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Add New Lead'),
      drawer: CustomDrawer(
        currentUserRole: 'Lead Manager',
        currentUserName: _userName,
      ),
      body: Container(
        color: const Color(0xFF2c5aa0),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF17a2b8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Add New Lead',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // First Row - Lead Name and Contact
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lead Name *',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter lead name',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter lead name';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Contact *',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _contactController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter contact number',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter contact number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Second Row - Email and Education
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter email',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value != null && value.isNotEmpty) {
                                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Education',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _educationController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter education',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Third Row - Experience and Location
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Experience',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _experienceController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter experience',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _locationController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter location',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Fourth Row - Lead Owner and Assign To
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lead Owner (Lead Manager)',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedLeadManager,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: _leadManagers.map((manager) {
                                  return DropdownMenuItem(
                                    value: manager,
                                    child: Text(manager),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedLeadManager = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Assign To (BA Specialist)',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                initialValue: _selectedBASpecialist,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: _baSpecialists.map((specialist) {
                                  return DropdownMenuItem(
                                    value: specialist,
                                    child: Text(specialist),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedBASpecialist = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    
                    // Save Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _submitLead,
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'Save Lead',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2c5aa0),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}