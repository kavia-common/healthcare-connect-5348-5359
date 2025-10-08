import 'package:flutter/material.dart';
import '../models/consultation.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

// PUBLIC_INTERFACE
/// Reusable consultation card widget
class ConsultationCard extends StatelessWidget {
  final Consultation consultation;

  const ConsultationCard({
    super.key,
    required this.consultation,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = consultation.scheduledAt.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: isPast ? AppColors.textSecondary : AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    DateFormats.displayDateTime
                        .format(consultation.scheduledAt),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isPast
                              ? AppColors.textSecondary
                              : AppColors.text,
                        ),
                  ),
                ),
                if (isPast)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Past',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Upcoming',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(
              context,
              Icons.person,
              'Patient ID',
              consultation.patientId,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow(
              context,
              Icons.medical_services,
              'Doctor ID',
              consultation.doctorId,
            ),
            if (consultation.notes != null) ...[
              const SizedBox(height: AppSpacing.sm),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Notes:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                consultation.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
