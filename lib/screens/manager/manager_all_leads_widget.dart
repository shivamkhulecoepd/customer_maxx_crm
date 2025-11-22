import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:customer_maxx_crm/services/lead_service.dart';
import 'package:customer_maxx_crm/utils/api_service_locator.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';
import 'package:customer_maxx_crm/widgets/generic_table_view.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_bloc.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_state.dart';
import 'package:customer_maxx_crm/blocs/leads/leads_event.dart';

class ManagerAllLeadsWidget extends StatefulWidget {
  const ManagerAllLeadsWidget({super.key});

  @override
  State<ManagerAllLeadsWidget> createState() => _ManagerAllLeadsWidgetState();
}

class _ManagerAllLeadsWidgetState extends State<ManagerAllLeadsWidget> {
  bool _hasLoadedInitialData = false;

  // Filters
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedStatus;

  final List<String> _statusOptions = [
    'Pending',
    'Connected',
    'Not Connected',
    'Follow-up Planned',
    'Follow-up Completed',
    'Registered',
  ];

  @override
  void initState() {
    super.initState();
    // Load initial data will be handled in the build method with addPostFrameCallback
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showFilterModal(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? AppThemes.darkCardBackground : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Leads',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppThemes.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Lead Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.flag),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ..._statusOptions.map(
                  (status) =>
                      DropdownMenuItem(value: status, child: Text(status)),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
              },
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: _selectedDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _selectedDate = null),
                        )
                      : null,
                ),
                child: Text(
                  _selectedDate != null
                      ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                      : 'Select Date',
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Apply filters would need to be implemented
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemes.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDarkMode = state.isDarkMode;
        return _buildBody(isDarkMode);
      },
    );
  }

  Widget _buildBody(bool isDarkMode) {
    return BlocBuilder<LeadsBloc, LeadsState>(
      builder: (context, leadsState) {
        // Load leads data only when needed (first time)
        if (!_hasLoadedInitialData &&
            leadsState.leads.isEmpty &&
            !leadsState.isLoading &&
            leadsState.error == null) {
          // Use addPostFrameCallback to avoid calling during build phase
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<LeadsBloc>().add(LoadAllLeads());
            setState(() {
              _hasLoadedInitialData = true;
            });
          });
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Reset the flag and load fresh data
            setState(() {
              _hasLoadedInitialData = false;
            });
            context.read<LeadsBloc>().add(LoadAllLeads());
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: Builder(
            builder: (context) {
              if (leadsState.isLoading && leadsState.leads.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (leadsState.error != null && leadsState.leads.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${leadsState.error}'),
                      ElevatedButton(
                        onPressed: () {
                          context.read<LeadsBloc>().add(LoadAllLeads());
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final leads = leadsState.leads;

              return GenericTableView<Lead>(
                title: 'All Leads',
                data: leads,
                columns: [
                  GenericTableColumn(
                    title: 'ID',
                    value: (lead) => lead.id.toString(),
                    width: 60,
                  ),
                  GenericTableColumn(
                    title: 'Name',
                    value: (lead) => lead.name,
                    width: 150,
                  ),
                  GenericTableColumn(
                    title: 'Phone',
                    value: (lead) => lead.phone,
                    width: 120,
                  ),
                  GenericTableColumn(
                    title: 'Email',
                    value: (lead) => lead.email,
                    width: 150,
                  ),
                  GenericTableColumn(
                    title: 'Status',
                    value: (lead) => lead.status,
                    width: 120,
                    builder: (lead) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppThemes.getStatusColor(lead.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lead.status.isEmpty ? 'N/A' : lead.status,
                        style: TextStyle(
                          color: AppThemes.getStatusColor(lead.status.isEmpty ? 'New' : lead.status),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  GenericTableColumn(
                    title: 'Created',
                    value: (lead) => lead.createdAt.isNotEmpty
                        ? DateFormat('MMM d, y').format(DateTime.parse(lead.createdAt))
                        : 'N/A',
                    width: 120,
                  ),
                  GenericTableColumn(
                    title: 'Owner',
                    value: (lead) => lead.ownerName,
                    width: 120,
                  ),
                  GenericTableColumn(
                    title: 'Assigned To',
                    value: (lead) => lead.assignedName,
                    width: 120,
                  ),
                ],
                onRowTap: (lead) {
                  _showLeadDetails(lead);
                },
                showSearch: true,
                showFilter: true,
                showExport: true,
                onFilterChanged: (filter) {
                  // Handle filter change if needed
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading(bool isDarkMode) {
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header shimmer
            Container(
              height: 60,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Table rows shimmer
            for (int i = 0; i < 10; i++)
              Container(
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error, bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppThemes.redAccent,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading leads',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppThemes.darkSecondaryText : AppThemes.lightSecondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasLoadedInitialData = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemes.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: isDarkMode ? Colors.white54 : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No leads found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppThemes.darkSecondaryText : AppThemes.lightSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  void _showLeadDetails(Lead lead) {
    // Create a stateful widget for the bottom sheet to manage history data
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) =>
          _LeadDetailsBottomSheet(lead: lead, leadService: ServiceLocator.leadService),
    );
  }
}

class _LeadDetailsBottomSheet extends StatefulWidget {
  final Lead lead;
  final LeadService leadService;

  const _LeadDetailsBottomSheet({
    required this.lead,
    required this.leadService,
  });

  @override
  State<_LeadDetailsBottomSheet> createState() =>
      _LeadDetailsBottomSheetState();
}

class _LeadDetailsBottomSheetState extends State<_LeadDetailsBottomSheet> {
  List<LeadHistory> _leadHistory = [];
  bool _isLoadingHistory = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchLeadHistory();
  }

  Future<void> _fetchLeadHistory() async {
    try {
      final history = await widget.leadService.getLeadHistory(widget.lead.id);
      // Always update state, regardless of mounted status
      setState(() {
        _leadHistory = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      // Always update state, regardless of mounted status
      setState(() {
        _isLoadingHistory = false;
        _errorMessage = 'Failed to load lead history: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load lead history: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.5), width: 2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 5,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lead Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow('Name', widget.lead.name),
                    _buildDetailRow('Email', widget.lead.email),
                    _buildDetailRow('Phone', widget.lead.phone),
                    _buildDetailRow('Education', widget.lead.education),
                    _buildDetailRow('Experience', widget.lead.experience),
                    _buildDetailRow('Location', widget.lead.location),
                    _buildDetailRow('Current Status', widget.lead.status),
                    _buildDetailRow('Feedback', widget.lead.feedback),
                    _buildDetailRow('Created At', widget.lead.createdAt),
                    _buildDetailRow('Owner', widget.lead.ownerName),
                    _buildDetailRow('Assigned To', widget.lead.assignedName),
                    const SizedBox(height: 20),
                    const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_isLoadingHistory)
                      const Center(child: CircularProgressIndicator())
                    else if (_errorMessage.isNotEmpty)
                      Center(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else if (_leadHistory.isEmpty)
                      const Center(
                        child: Text(
                          'No history available',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: _leadHistory.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryItem(_leadHistory[index]);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(LeadHistory history) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (history.status != null && history.status!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppThemes.getStatusColor(
                      history.status!,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    history.status!,
                    style: TextStyle(
                      color: AppThemes.getStatusColor(history.status!),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(
                history.updatedAt,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          if (history.feedback != null && history.feedback!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(history.feedback!, style: const TextStyle(fontSize: 14)),
          ],
          const SizedBox(height: 4),
          Text(
            'Updated by: ${history.updatedBy} (${history.role})',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}