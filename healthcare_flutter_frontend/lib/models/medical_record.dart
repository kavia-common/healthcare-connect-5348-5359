class MedicalRecord {
  final String id;
  final String patientId;
  final List<String> entries;

  MedicalRecord({
    required this.id,
    required this.patientId,
    required this.entries,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'entries': entries,
    };
  }
}
