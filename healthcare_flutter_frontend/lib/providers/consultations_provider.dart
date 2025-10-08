import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class ConsultationsProvider extends ChangeNotifier {
  final ApiClient _client;
  bool _loading = false;
  List<Map<String, dynamic>> _items = [];

  ConsultationsProvider(this._client);

  bool get isLoading => _loading;
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  Future<void> fetch() async {
    /** Fetch consultations for current user scope. */
    _setLoading(true);
    try {
      final resp = await _client.get('/consultations');
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List<dynamic>;
        _items = data.cast<Map<String, dynamic>>();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch consultations: ${resp.statusCode}');
      }
    } finally {
      _setLoading(false);
    }
  }

  // PUBLIC_INTERFACE
  Future<void> create({required String patientId, required String scheduledAt, String? notes, String? doctorId}) async {
    /** Create a new consultation. Doctor id optional (inferred for doctor role). */
    final body = {
      'patient_id': patientId,
      'scheduled_at': scheduledAt,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (doctorId != null && doctorId.isNotEmpty) 'doctor_id': doctorId,
    };
    final resp = await _client.post('/consultations', body: body);
    if (resp.statusCode == 201) {
      await fetch();
    } else {
      throw Exception('Failed to create consultation: ${resp.statusCode} ${resp.body}');
    }
  }
}
