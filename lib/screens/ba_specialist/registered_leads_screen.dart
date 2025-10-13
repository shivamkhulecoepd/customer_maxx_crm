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
  late String _userName;

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
                const Text(
                  'Registered Leads',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
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
                        columns: const [
                          DataColumn(label: Text('Sr No')),
                          DataColumn(label: Text('Name')),
                          DataColumn(label: Text('Contact')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Education-Experience')),
                          DataColumn(label: Text('City')),
                          DataColumn(label: Text('Lead Owner/BA Specialist')),
                          DataColumn(label: Text('Discount')),
                          DataColumn(label: Text('First Installment')),
                          DataColumn(label: Text('Second Installment')),
                          DataColumn(label: Text('Final Fee')),
                        ],
                        rows: leadsProvider.leads.asMap().entries.map((entry) {
                          final index = entry.key;
                          final lead = entry.value;
                          
                          return DataRow(
                            cells: [
                              DataCell(Text((index + 1).toString())),
                              DataCell(Text(lead.name)),
                              DataCell(Text(lead.phone)),
                              DataCell(Text(lead.email)),
                              DataCell(Text('${lead.education}-${lead.experience}')),
                              DataCell(Text(lead.location)),
                              DataCell(Text(lead.leadManager)),
                              DataCell(Text(lead.discount?.toString() ?? '')),
                              DataCell(Text(lead.firstInstallment?.toString() ?? '')),
                              DataCell(Text(lead.secondInstallment?.toString() ?? '')),
                              DataCell(Text(lead.finalFee?.toString() ?? '')),
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