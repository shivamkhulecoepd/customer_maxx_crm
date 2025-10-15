import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_event.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_state.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';
import 'package:customer_maxx_crm/widgets/modern_drawer.dart';

class AllLeadsScreen extends StatefulWidget {
  const AllLeadsScreen({super.key});

  @override
  State<AllLeadsScreen> createState() => _AllLeadsScreenState();
}

class _AllLeadsScreenState extends State<AllLeadsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<LeadsBloc>(context).add(LoadAllLeads());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'All Leads'),
      drawer: const ModernDrawer(), // No parameters needed now
      body: BlocBuilder<LeadsBloc, LeadsState>(
        builder: (context, leadsState) {
          return Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: const Text(
                    'All Leads Screen',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: leadsState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : leadsState.leads.isEmpty
                          ? const Center(child: Text('No leads found'))
                          : ListView.builder(
                              itemCount: leadsState.leads.length,
                              itemBuilder: (context, index) {
                                final lead = leadsState.leads[index];
                                return Card(
                                  margin: const EdgeInsets.all(8),
                                  child: ListTile(
                                    title: Text(lead.name),
                                    subtitle: Text('${lead.phone} - ${lead.status}'),
                                    trailing: Text(lead.leadManager),
                                  ),
                                );
                              },
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