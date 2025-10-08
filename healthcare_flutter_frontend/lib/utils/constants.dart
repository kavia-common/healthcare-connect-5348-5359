import 'package:intl/intl.dart';

class ApiEndpoints {
  static const String login = '/auth/login_json';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String patients = '/patients';
  static const String doctors = '/doctors';
  static const String consultations = '/consultations';
  static const String medicalRecords = '/medical_records';

  // Helper to build endpoint with ID
  static String patientById(String id) => '/patients/$id';
  static String doctorById(String id) => '/doctors/$id';
  static String consultationById(String id) => '/consultations/$id';
  static String medicalRecordById(String id) => '/medical_records/$id';
}

class StorageKeys {
  static const String token = 'auth_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
}

class DateFormats {
  static final DateFormat displayDate = DateFormat('MMM dd, yyyy');
  static final DateFormat displayDateTime = DateFormat('MMM dd, yyyy hh:mm a');
  static final DateFormat apiDateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
}

class AppConstants {
  static const String appName = 'Healthcare Connect';
  static const int networkTimeout = 30; // seconds
}
