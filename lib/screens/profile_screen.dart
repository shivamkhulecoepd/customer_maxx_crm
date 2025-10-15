import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_maxx_crm/blocs/auth/auth_bloc.dart';
import 'package:customer_maxx_crm/widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        onLeadingPressed: () {
          Navigator.pop(context);
        },
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user = (authState is Authenticated) ? authState.user : null;
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Color(0xFF00BCD4),
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user?.name ?? 'John Doe',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${user?.name ?? 'John Doe'} - ${user?.role ?? 'Admin'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Profile details
                  const Text(
                    'Profile Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildProfileField(Icons.email, 'Email', user?.email ?? ''),
                  const SizedBox(height: 16),
                  
                  _buildProfileField(Icons.phone, 'Phone', ''),
                  const SizedBox(height: 16),
                  
                  _buildProfileField(Icons.location_on, 'Address', ''),
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement edit profile functionality
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00BCD4)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? 'Not provided' : value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}