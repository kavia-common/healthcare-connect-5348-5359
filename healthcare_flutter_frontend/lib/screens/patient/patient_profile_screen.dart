import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/patient.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

// PUBLIC_INTERFACE
/// Patient profile screen for viewing and editing profile
class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  final ApiService _apiService = ApiService();
  Patient? _patient;
  bool _isLoading = true;
  bool _isEditing = false;

  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _genderController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      await _apiService.initialize();

      // Get all patients and find ours by user_id
      final response = await _apiService.get(ApiEndpoints.patients);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final userId = authProvider.user?.id;
        
        final patientData = data.firstWhere(
          (p) => p['user_id'] == userId,
          orElse: () => null,
        );

        if (patientData != null) {
          _patient = Patient.fromJson(patientData);
          _ageController.text = _patient?.age?.toString() ?? '';
          _genderController.text = _patient?.gender ?? '';
          _addressController.text = _patient?.address ?? '';
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
    if (_patient == null) return;

    try {
      final body = <String, dynamic>{};
      if (_ageController.text.isNotEmpty) {
        body['age'] = int.tryParse(_ageController.text);
      }
      if (_genderController.text.isNotEmpty) {
        body['gender'] = _genderController.text;
      }
      if (_addressController.text.isNotEmpty) {
        body['address'] = _addressController.text;
      }

      final response = await _apiService.patch(
        ApiEndpoints.patientById(_patient!.id),
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
                    'Medical Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  if (_isEditing) ...[
                    TextField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _genderController,
                      decoration: const InputDecoration(labelText: 'Gender'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('Save Changes'),
                    ),
                  ] else ...[
                    _buildInfoRow('Age', _patient?.age?.toString() ?? 'Not set'),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoRow('Gender', _patient?.gender ?? 'Not set'),
                    const SizedBox(height: AppSpacing.md),
                    _buildInfoRow('Address', _patient?.address ?? 'Not set'),
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
