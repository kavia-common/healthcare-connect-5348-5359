import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/consultation.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import '../../widgets/consultation_card.dart';

// PUBLIC_INTERFACE
/// Doctor consultations screen for viewing and managing appointments
class DoctorConsultationsScreen extends StatefulWidget {
  const DoctorConsultationsScreen({super.key});

  @override
  State<DoctorConsultationsScreen> createState() =>
      _DoctorConsultationsScreenState();
}

class _DoctorConsultationsScreenState
    extends State<DoctorConsultationsScreen> {
  final ApiService _apiService = ApiService();
  List<Consultation> _consultations = [];
  bool _isLoading = true;
  String? _doctorId;

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

      // First get doctor profile to get doctor_id
      final doctorResponse = await _apiService.get(ApiEndpoints.doctors);
      if (doctorResponse.statusCode == 200) {
        final List<dynamic> doctors = jsonDecode(doctorResponse.body);
        final userId = authProvider.user?.id;
        final doctorData = doctors.firstWhere(
          (d) => d['user_id'] == userId,
          orElse: () => null,
        );

        if (doctorData != null) {
          _doctorId = doctorData['id'];

          // Now get consultations
          final response = await _apiService.get(ApiEndpoints.consultations);
          if (response.statusCode == 200) {
            final List<dynamic> data = jsonDecode(response.body);
            _consultations = data
                .map((json) => Consultation.fromJson(json))
                .where((c) => c.doctorId == _doctorId)
                .toList();
            _consultations
                .sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
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
