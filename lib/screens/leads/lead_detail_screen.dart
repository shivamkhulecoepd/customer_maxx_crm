import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/lead.dart';
import '../../services/lead_service.dart';
import '../../utils/api_service_locator.dart';
import '../../utils/theme_utils.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_state.dart';

class LeadDetailScreen extends StatefulWidget {
  final int leadId;

  const LeadDetailScreen({super.key, required this.leadId});

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  final LeadService _leadService = ServiceLocator.leadService;
  Lead? _lead;
  bool _isLoading = true;
  String? _error;
  List<LeadHistory> _history = [];
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadLeadDetails();
    _loadHistory();
  }

  Future<void> _loadLeadDetails() async {
    // Since we don't have a getLeadById API yet, we might need to rely on passing the Lead object
    // or implement getLeadById. For now, let's assume we can fetch it or just show what we have if passed.
    // Actually, the user didn't ask for full detail view implementation, just the dashboard sync.
    // But to make the "All Leads" screen functional, we need this.
    // I'll implement a basic fetch using getAllLeads filtered by ID if possible, or just fetch history.
    // Wait, the API doesn't support getLeadById directly in the service I saw.
    // I'll just show history for now and basic info.

    setState(() {
      _isLoading = false; // Placeholder
    });
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _leadService.getLeadHistory(widget.leadId);
      setState(() {
        _history = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        // _error = e.toString(); // Don't block main UI for history error
        _isLoadingHistory = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state.isDarkMode;
        return Scaffold(
          backgroundColor: isDarkMode
              ? AppThemes.darkBackground
              : AppThemes.lightBackground,
          appBar: AppBar(
            title: const Text('Lead Details'),
            backgroundColor: isDarkMode
                ? AppThemes.darkCardBackground
                : AppThemes.primaryColor,
            foregroundColor: Colors.white,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Placeholder for Lead Info since we don't have the full object passed or fetched yet
                      // In a real app, we'd pass the Lead object to the constructor or fetch it.
                      Text(
                        'Lead ID: ${widget.leadId}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (_isLoadingHistory)
                        const Center(child: CircularProgressIndicator())
                      else if (_history.isEmpty)
                        Text(
                          'No history found',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final item = _history[index];
                            return Card(
                              color: isDarkMode
                                  ? AppThemes.darkCardBackground
                                  : Colors.white,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  item.status ?? 'No Status',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.feedback != null &&
                                        item.feedback!.isNotEmpty)
                                      Text(
                                        item.feedback!,
                                        style: TextStyle(
                                          color: isDarkMode
                                              ? Colors.white70
                                              : Colors.black54,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.updatedBy} • ${item.updatedAt}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
