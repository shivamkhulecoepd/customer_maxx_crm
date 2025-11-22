import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_bloc.dart';
import 'package:customer_maxx_crm/blocs/theme/theme_state.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';
import 'package:customer_maxx_crm/models/lead.dart';
import 'package:customer_maxx_crm/models/user.dart';
import 'package:customer_maxx_crm/services/lead_service.dart';
import 'package:customer_maxx_crm/utils/api_service_locator.dart';
import 'package:customer_maxx_crm/widgets/generic_table_view.dart';
import 'package:intl/intl.dart';

class StaleLeadsWidget extends StatefulWidget {
  const StaleLeadsWidget({super.key});

  @override
  State<StaleLeadsWidget> createState() => _StaleLeadsWidgetState();
}

class _StaleLeadsWidgetState extends State<StaleLeadsWidget> {
  late LeadService _leadService;
  List<Lead> _leads = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  List<UserRole> _baSpecialists = [];

  bool _hasLoadedInitialData = false;

  @override
  void initState() {
    super.initState();
    _leadService = ServiceLocator.leadService;
    _loadBASpecialists();
    _scrollController.addListener(_onScroll);
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeads();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoading &&
        _hasMore) {
      _loadLeads();
    }
  }

  Future<void> _loadBASpecialists() async {
    try {
      final specialists = await _leadService.getBASpecialists();
      setState(() {
        _baSpecialists = specialists;
      });
    } catch (e) {
      // Handle error silently or show snackbar
      print('Error loading BA specialists: $e');
    }
  }

  Future<void> _loadLeads() async {
    if (_isLoading && _page > 1) return;

    setState(() {
      _isLoading = true;
      if (_page == 1) _error = null;
    });

    try {
      final leads = await _leadService.getStaleLeads(page: _page);
      setState(() {
        if (_page == 1) {
          _leads = leads;
        } else {
          _leads.addAll(leads);
        }
        _hasMore = leads.length >= 20;
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _reassignLead(Lead lead) async {
    UserRole? selectedUser;
    final result = await showDialog<UserRole>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reassign Lead'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reassign ${lead.name} to:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserRole>(
              items: _baSpecialists
                  .map(
                    (user) =>
                        DropdownMenuItem(value: user, child: Text(user.name)),
                  )
                  .toList(),
              onChanged: (value) {
                selectedUser = value;
              },
              decoration: const InputDecoration(
                labelText: 'Select Specialist',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, selectedUser),
            child: const Text('Reassign'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        // Create updated lead object
        final updatedLead = Lead(
          id: lead.id,
          name: lead.name,
          phone: lead.phone,
          email: lead.email,
          status: lead.status,
          feedback: 'Reassigned from stale status',
          assignedTo: int.tryParse(result.id),
          // Required fields - passing current values or empty strings if not available
          ownerName: lead.ownerName,
          assignedName: lead.assignedName,
          latestHistory: lead.latestHistory,
          // Copy other fields...
          education: lead.education,
          experience: lead.experience,
          location: lead.location,
          createdAt: lead.createdAt,
        );

        await _leadService.updateLead(updatedLead);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lead reassigned successfully')),
          );
        }

        // Refresh list
        _page = 1;
        _loadLeads();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to reassign: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.isDarkMode;
        return _buildBody(isDarkMode);
      },
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (_isLoading && _leads.isEmpty) {
      return _buildShimmerLoading(isDarkMode);
    }

    if (_error != null && _leads.isEmpty) {
      return _buildErrorView(_error!, isDarkMode);
    }

    if (_leads.isEmpty) {
      return _buildEmptyView(isDarkMode);
    }

    return RefreshIndicator(
      onRefresh: () async {
        _page = 1;
        await _loadLeads();
      },
      child: GenericTableView<Lead>(
        title: 'Stale Leads',
        data: _leads,
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
            value: (lead) => DateFormat('MMM d, y').format(DateTime.parse(lead.createdAt)),
            width: 120,
          ),
          GenericTableColumn(
            title: 'Assigned To',
            value: (lead) => lead.assignedName,
            width: 120,
          ),
        ],
        onRowTap: (lead) {
          // Handle row tap if needed
        },
        onRowReassign: (lead) {
          _reassignLead(lead);
        },
        showSearch: true,
        showFilter: true,
        showExport: true,
      ),
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
            'Error loading stale leads',
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
              _page = 1;
              _loadLeads();
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
            'No stale leads found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : AppThemes.lightPrimaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'All leads are up to date',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? AppThemes.darkSecondaryText : AppThemes.lightSecondaryText,
            ),
          ),
        ],
      ),
    );
  }
}