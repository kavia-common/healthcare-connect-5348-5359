import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/api_client.dart';

class MedicalRecordsProvider extends ChangeNotifier {
  final ApiClient _client;
  bool _loading = false;
  List<Map<String, dynamic>> _items = [];

  MedicalRecordsProvider(this._client);

  bool get isLoading => _loading;
  List<Map<String, dynamic>> get items => List.unmodifiable(_items);

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  // PUBLIC_INTERFACE
  Future<void> fetch({String? patientId}) async {
    /** Fetch medical records; doctors should pass patientId filter. */
    _setLoading(true);
    try {
      final resp = await _client.get('/medical_records', query: {'patient_id': patientId});
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as List<dynamic>;
        _items = data.cast<Map<String, dynamic>>();
        notifyListeners();
      } else {
        throw Exception('Failed to fetch medical records: ${resp.statusCode}');
      }
    } finally {
      _setLoading(false);
    }
  }

  // PUBLIC_INTERFACE
  Future<void> create({required String patientId, List<String>? entries}) async {
    /** Create a new medical record (admin/doctor only). */
    final resp = await _client.post('/medical_records', body: {
      'patient_id': patientId,
      if (entries != null) 'entries': entries,
    });
    if (resp.statusCode == 201) {
      await fetch(patientId: patientId);
    } else {
      throw Exception('Failed to create medical record: ${resp.statusCode} ${resp.body}');
    }
  }
}
