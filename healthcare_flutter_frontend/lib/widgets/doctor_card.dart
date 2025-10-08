import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../utils/theme.dart';

// PUBLIC_INTERFACE
/// Reusable doctor card widget
class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: const Icon(
            Icons.medical_services,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Dr. ${doctor.userId}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            if (doctor.specialty != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.local_hospital,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(doctor.specialty!),
                ],
              ),
            ],
            if (doctor.bio != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                doctor.bio!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Could navigate to doctor detail screen
        },
      ),
    );
  }
}
