class Patient {
  final String id;
  final String userId;
  final int? age;
  final String? gender;
  final String? address;

  Patient({
    required this.id,
    required this.userId,
    this.age,
    this.gender,
    this.address,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'age': age,
      'gender': gender,
      'address': address,
    };
  }
}
