import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/services/cron_service.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';
import 'package:customer_maxx_crm/utils/api_service_locator.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  _SystemSettingsScreenState createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final CronService _cronService = ServiceLocator.cronService;
  bool _isLoading = false;
  String? _lastResult;

  Future<void> _runCron(String type, String label) async {
    setState(() {
      _isLoading = true;
      _lastResult = null;
    });

    try {
      final result = await _cronService.runCron(type);
      setState(() {
        _lastResult = 'Success: ${result['message']}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label executed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _lastResult = 'Error: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to run $label: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        backgroundColor: AppThemes.darkCardBackground,
      ),
      backgroundColor: AppThemes.darkBackground,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Maintenance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manually trigger system cron jobs to update lead statuses and send notifications.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildCronCard(
                'Stale Leads Check',
                'Checks for leads not connected > 7 days and reassigns them.',
                Icons.timer_off,
                () => _runCron('stale_leads', 'Stale Leads Cron'),
              ),
              const SizedBox(height: 16),
              _buildCronCard(
                'Pending Leads Check',
                'Notifies owners of leads pending > 3 days.',
                Icons.pending_actions,
                () => _runCron('pending_leads', 'Pending Leads Cron'),
              ),
              const SizedBox(height: 16),
              _buildCronCard(
                'Follow-up Reminders',
                'Notifies owners of follow-ups with no activity > 2 days.',
                Icons.notification_important,
                () => _runCron('follow_up_reminder', 'Follow-up Cron'),
              ),
              const SizedBox(height: 16),
              _buildCronCard(
                'Run All Checks',
                'Executes all system checks sequentially.',
                Icons.playlist_play,
                () => _runCron('all', 'All System Checks'),
              ),
            ],
            if (_lastResult != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  _lastResult!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCronCard(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      color: AppThemes.darkCardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppThemes.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppThemes.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.play_arrow, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
