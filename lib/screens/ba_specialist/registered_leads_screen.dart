import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_event.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_state.dart';
import 'package:customer_maxx_crm/widgets/app_bar.dart';
import 'package:customer_maxx_crm/widgets/app_drawer.dart';

class RegisteredLeadsScreen extends StatefulWidget {
  const RegisteredLeadsScreen({super.key});

  @override
  State<RegisteredLeadsScreen> createState() => _RegisteredLeadsScreenState();
}

class _RegisteredLeadsScreenState extends State<RegisteredLeadsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BlocProvider.of<LeadsBloc>(context).add(LoadLeadsByStatus('Registered'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ModernAppBar(title: 'Registered Leads', userName: '', userEmail: ''),
      drawer: const ModernDrawer(), // No parameters needed now
      body: BlocBuilder<LeadsBloc, LeadsState>(
        builder: (context, leadsState) {
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
                        rows: leadsState.leads.where((lead) => 
                          lead.status.toLowerCase() == 'registered'
                        ).toList().asMap().entries.map((entry) {
                          final index = entry.key;
                          final lead = entry.value;
                          
                          return DataRow(
                            color: WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                              return index.isEven
                                  ? Colors.grey.withValues(alpha: 0.1)
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