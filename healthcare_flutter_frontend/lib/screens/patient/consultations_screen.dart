import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/consultation.dart';
import '../../models/patient.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/consultation_card.dart';

// PUBLIC_INTERFACE
/// Consultations screen for patients to view and manage appointments
class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({super.key});

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  final ApiService _apiService = ApiService();
  List<Consultation> _consultations = [];
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

          // Now get consultations
          final response = await _apiService.get(ApiEndpoints.consultations);
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            _consultations = data
                .map((json) => Consultation.fromJson(json))
                .where((c) => c.patientId == _patientId)
                .toList();
            _consultations.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading consultations: $e')),
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

    if (_consultations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No consultations yet',
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
        itemCount: _consultations.length,
        itemBuilder: (context, index) {
          return ConsultationCard(
            consultation: _consultations[index],
          );
        },
      ),
    );
  }
}
