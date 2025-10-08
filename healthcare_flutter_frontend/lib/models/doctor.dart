class Doctor {
  final String id;
  final String userId;
  final String? specialty;
  final String? bio;

  Doctor({
    required this.id,
    required this.userId,
    this.specialty,
    this.bio,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      specialty: json['specialty'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'specialty': specialty,
      'bio': bio,
    };
  }
}
