import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/lead.dart';
import '../../services/lead_service.dart';
import '../../utils/api_service_locator.dart';
import '../../utils/theme_utils.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_state.dart';
import '../../widgets/generic_table_view.dart';
import '../leads/lead_detail_screen.dart';

class ManagerAllLeadsScreen extends StatefulWidget {
  const ManagerAllLeadsScreen({super.key});

  @override
  State<ManagerAllLeadsScreen> createState() => _ManagerAllLeadsScreenState();
}

class _ManagerAllLeadsScreenState extends State<ManagerAllLeadsScreen> {
  final LeadService _leadService = ServiceLocator.leadService;
  final ScrollController _scrollController = ScrollController();

  List<Lead> _leads = [];
  bool _isLoading = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;

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

  bool _hasLoadedInitialData = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadLeads();
    }
  }

  Future<void> _loadLeads({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      setState(() {
        _leads = [];
        _page = 1;
        _hasMore = true;
        _error = null;
      });
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final leads = await _leadService.getAllLeads(
        page: _page,
        limit: 20,
        name: _nameController.text.isNotEmpty ? _nameController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        date: _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : null,
        status: _selectedStatus,
      );

      setState(() {
        if (refresh) {
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
                  _loadLeads(refresh: true);
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
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: _buildCustomAppBar(context, isDarkMode),
            centerTitle: true,
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
          ),
          body: _buildBody(isDarkMode),
        );
      },
    );
  }

  Widget _buildBody(bool isDarkMode) {
    // Load data only when needed (first time)
    if (!_hasLoadedInitialData &&
        _leads.isEmpty &&
        !_isLoading &&
        _error == null) {
      // Use addPostFrameCallback to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadLeads();
        setState(() {
          _hasLoadedInitialData = true;
        });
      });
    }

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
        // Reset the flag and load fresh data
        setState(() {
          _hasLoadedInitialData = false;
        });
        await _loadLeads(refresh: true);
      },
      child: GenericTableView<Lead>(
        title: 'All Leads',
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LeadDetailScreen(leadId: lead.id),
            ),
          );
        },
        showSearch: true,
        showFilter: true,
        showExport: true,
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'registered':
        color = Colors.green;
        break;
      case 'connected':
        color = Colors.blue;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'not connected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, bool isDarkMode) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.transparent,
      child: Row(
        children: [
          // Back Button
          Builder(
            builder: (BuildContext context) {
              return _buildIconButton(
                context,
                Icons.arrow_back_ios,
                () => Navigator.pop(context),
                isDarkMode,
              );
            },
          ),
          SizedBox(width: width < 360 ? 8 : 12),

          // Title
          Expanded(
            child: Text(
              "All Leads",
              style: TextStyle(
                fontSize: width < 360 ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Filter Icon
          _buildIconButton(
            context,
            Icons.filter_list,
            () => _showFilterModal(isDarkMode),
            isDarkMode,
          ),

          SizedBox(width: width < 360 ? 6 : 8),
        ],
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
    bool isDarkMode,
  ) {
    final width = MediaQuery.of(context).size.width;
    final buttonSize = width < 360 ? 36.0 : 44.0;
    final iconSize = width < 360 ? 18.0 : 20.0;

    return Container(
      width: buttonSize,
      height: buttonSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(width < 360 ? 10 : 12),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
          size: iconSize,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
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
            onPressed: () => _loadLeads(refresh: true),
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

  Widget _buildInfoRow(IconData icon, String text, bool isDarkMode) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDarkMode ? Colors.white60 : Colors.black54,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
