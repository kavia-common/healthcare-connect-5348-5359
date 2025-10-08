import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/medical_record.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/medical_record_card.dart';

// PUBLIC_INTERFACE
/// Medical records screen for viewing patient medical history
class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final ApiService _apiService = ApiService();
  List<MedicalRecord> _records = [];
  bool _isLoading = true;
  String? _patientId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      await _apiService.initialize();

      // First get patient profile to get patient_id
      final patientResponse = await _apiService.get(ApiEndpoints.patients);
      if (patientResponse.statusCode == 200) {
        final List<dynamic> patients = jsonDecode(patientResponse.body);
        final userId = authProvider.user?.id;
        final patientData = patients.firstWhere(
          (p) => p['user_id'] == userId,
          orElse: () => null,
        );

        if (patientData != null) {
          _patientId = patientData['id'];

          // Now get medical records
          final response = await _apiService.get(
            '${ApiEndpoints.medicalRecords}?patient_id=$_patientId',
          );
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            _records = data.map((json) => MedicalRecord.fromJson(json)).toList();
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading records: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No medical records yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          return MedicalRecordCard(record: _records[index]);
        },
      ),
    );
  }
}
