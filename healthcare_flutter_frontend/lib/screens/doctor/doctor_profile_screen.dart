import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/doctor.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

// PUBLIC_INTERFACE
/// Doctor profile screen for viewing and editing profile
class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final ApiService _apiService = ApiService();
  Doctor? _doctor;
  bool _isLoading = true;
  bool _isEditing = false;

  final _specialtyController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _specialtyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      await _apiService.initialize();

      // Get all doctors and find ours by user_id
      final response = await _apiService.get(ApiEndpoints.doctors);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final userId = authProvider.user?.id;
        
        final doctorData = data.firstWhere(
          (d) => d['user_id'] == userId,
          orElse: () => null,
        );

        if (doctorData != null) {
          _doctor = Doctor.fromJson(doctorData);
          _specialtyController.text = _doctor?.specialty ?? '';
          _bioController.text = _doctor?.bio ?? '';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (_doctor == null) return;

    try {
      final body = <String, dynamic>{};
      if (_specialtyController.text.isNotEmpty) {
        body['specialty'] = _specialtyController.text;
      }
      if (_bioController.text.isNotEmpty) {
        body['bio'] = _bioController.text;
      }

      final response = await _apiService.patch(
        ApiEndpoints.doctorById(_doctor!.id),
        body,
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() => _isEditing = false);
        await _loadProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Profile Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_isEditing ? Icons.close : Icons.edit),
                        onPressed: () {
                          setState(() => _isEditing = !_isEditing);
                        },
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow('Email', user?.email ?? 'N/A'),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow('Name', user?.fullName ?? 'N/A'),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoRow('Role', user?.role.toUpperCase() ?? 'N/A'),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Professional Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  if (_isEditing) ...[
                    TextField(
                      controller: _specialtyController,
                      decoration: const InputDecoration(labelText: 'Specialty'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: 'Bio'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('Save Changes'),
                    ),
                  ] else ...[
                    _buildInfoRow(
                        'Specialty', _doctor?.specialty ?? 'Not set'),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoRow('Bio', _doctor?.bio ?? 'Not set'),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
