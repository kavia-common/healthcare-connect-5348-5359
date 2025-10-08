class Consultation {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime scheduledAt;
  final String? notes;

  Consultation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.scheduledAt,
    this.notes,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      doctorId: json['doctor_id'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'scheduled_at': scheduledAt.toIso8601String(),
      'notes': notes,
    };
  }
}
