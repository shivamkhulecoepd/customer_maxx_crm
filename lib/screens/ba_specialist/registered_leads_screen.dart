import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:customer_maxx_crm/providers/auth_provider.dart';
import 'package:customer_maxx_crm/providers/leads_provider.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';
import 'package:customer_maxx_crm/widgets/custom_drawer.dart';

class RegisteredLeadsScreen extends StatefulWidget {
  const RegisteredLeadsScreen({Key? key}) : super(key: key);

  @override
  State<RegisteredLeadsScreen> createState() => _RegisteredLeadsScreenState();
}

class _RegisteredLeadsScreenState extends State<RegisteredLeadsScreen> {
  String _userName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        setState(() {
          _userName = authProvider.user?.name ?? 'shrikant';
        });
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
        leadsProvider.fetchLeadsByStatus('Registered');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Registered Leads'),
      drawer: CustomDrawer(
        currentUserRole: 'BA Specialist',
        currentUserName: _userName,
      ),
      body: Consumer<LeadsProvider>(
        builder: (context, leadsProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Registered Leads',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2c5aa0),
                  ),
                ),
                const SizedBox(height: 20),
                
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
                              'Sr. No',
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
                              'Contact',
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
                              'Education / Experience',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'City',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Lead Owner',
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
                              'Discount',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'First Installment',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Second Installment',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Final Fee',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                        rows: leadsProvider.leads.where((lead) => 
                          lead.status.toLowerCase() == 'registered'
                        ).toList().asMap().entries.map((entry) {
                          final index = entry.key;
                          final lead = entry.value;
                          
                          return DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                              return index.isEven
                                  ? Colors.grey.withOpacity(0.1)
                                  : null;
                            }),
                            cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(Text(lead.name)),
                              DataCell(Text(lead.phone)),
                              DataCell(Text(lead.email)),
                              DataCell(Text('${lead.education} / ${lead.experience}')),
                              DataCell(Text(lead.location)),
                              DataCell(Text(lead.leadManager)),
                              DataCell(Text(lead.assignedBy.isNotEmpty ? lead.assignedBy : 'shrikant')),
                              DataCell(
                                DropdownButton<String>(
                                  value: 'No Discount',
                                  items: ['No Discount', '10%', '20%', '30%'].map((discount) {
                                    return DropdownMenuItem(
                                      value: discount,
                                      child: Text(discount, style: const TextStyle(fontSize: 12)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    // Update discount
                                  },
                                  underline: Container(),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: '0.00',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              DataCell(
                                SizedBox(
                                  width: 80,
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      hintText: '0.00',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              DataCell(Text('41,300', style: const TextStyle(fontWeight: FontWeight.bold))),
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
}