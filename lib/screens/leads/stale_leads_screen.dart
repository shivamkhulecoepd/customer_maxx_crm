import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/lead_service.dart';
import '../../models/lead.dart';
import '../../models/user.dart';

import '../../utils/api_service_locator.dart';

class StaleLeadsScreen extends StatefulWidget {
  const StaleLeadsScreen({Key? key}) : super(key: key);

  @override
  State<StaleLeadsScreen> createState() => _StaleLeadsScreenState();
}

class _StaleLeadsScreenState extends State<StaleLeadsScreen> {
  late LeadService _leadService;
  List<Lead> _leads = [];
  bool _isLoading = true;
  String? _error;
  int _page = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  List<UserRole> _baSpecialists = [];

  @override
  void initState() {
    super.initState();
    _leadService = ServiceLocator.leadService;
    _loadLeads();
    _loadBASpecialists();
    _scrollController.addListener(_onScroll);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stale Leads'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _page = 1;
              _loadLeads();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _leads.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _leads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(
              onPressed: () {
                _page = 1;
                _loadLeads();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_leads.isEmpty) {
      return const Center(child: Text('No stale leads found'));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _leads.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _leads.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final lead = _leads[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(lead.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${lead.status}'),
                Text(
                  'Created: ${DateFormat('MMM d, y').format(DateTime.parse(lead.createdAt))}',
                ),
                if (lead.assignedName.isNotEmpty)
                  Text('Currently Assigned: ${lead.assignedName}'),
              ],
            ),
            // trailing: ElevatedButton(
            //   onPressed: () => _reassignLead(lead),
            //   child: const Text('Reassign'),
            // ),
            trailing: InkWell(
              onTap: () => _reassignLead(lead),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.green,
                ),
                child: const Text(
                  'Reassign',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
