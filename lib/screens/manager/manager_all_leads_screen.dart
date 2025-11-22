import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../models/lead.dart';
import '../../services/lead_service.dart';
import '../../utils/api_service_locator.dart';
import '../../utils/theme_utils.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_state.dart';
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

  @override
  void initState() {
    super.initState();
    _loadLeads();
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
          backgroundColor: isDarkMode
              ? AppThemes.darkBackground
              : AppThemes.lightBackground,
          appBar: AppBar(
            title: const Text('All Leads'),
            backgroundColor: isDarkMode
                ? AppThemes.darkCardBackground
                : AppThemes.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterModal(isDarkMode),
              ),
            ],
          ),
          body: _buildBody(isDarkMode),
        );
      },
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (_isLoading && _leads.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _leads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_error',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            ElevatedButton(
              onPressed: () => _loadLeads(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_leads.isEmpty) {
      return Center(
        child: Text(
          'No leads found',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadLeads(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _leads.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _leads.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final lead = _leads[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: isDarkMode ? AppThemes.darkCardBackground : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LeadDetailScreen(leadId: lead.id),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lead.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        _buildStatusBadge(lead.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.phone, lead.phone, isDarkMode),
                    const SizedBox(height: 4),
                    _buildInfoRow(Icons.email, lead.email, isDarkMode),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      Icons.calendar_today,
                      lead.date != null
                          ? DateFormat('MMM dd, yyyy').format(lead.date!)
                          : (lead.createdAt.isNotEmpty
                                ? DateFormat('MMM dd, yyyy').format(
                                    DateTime.tryParse(lead.createdAt) ??
                                        DateTime.now(),
                                  )
                                : 'N/A'),
                      isDarkMode,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: isDarkMode ? Colors.white60 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Owner: ${lead.ownerName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
