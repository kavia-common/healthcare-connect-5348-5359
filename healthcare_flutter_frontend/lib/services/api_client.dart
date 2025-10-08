import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/env.dart';

/// Lightweight API client for REST calls to the FastAPI backend.
class ApiClient {
  final String _baseUrl;

  ApiClient({String? baseUrl}) : _baseUrl = (baseUrl ?? Env.effectiveBaseUrl());

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    final trimmedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$_baseUrl$trimmedPath').replace(queryParameters: query?.map((k, v) => MapEntry(k, v?.toString())));
  }

  Future<Map<String, String>> _authHeaders() async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // PUBLIC_INTERFACE
  Future<http.Response> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    /** Perform a GET request. If auth=true, include bearer token when available. */
    final headers = auth ? await _authHeaders() : {'Accept': 'application/json'};
    final uri = _buildUri(path, query);
    return await http.get(uri, headers: headers);
  }

  // PUBLIC_INTERFACE
  Future<http.Response> post(String path, {Object? body, bool auth = true}) async {
    /** Perform a POST request with optional JSON body. */
    final headers = auth ? await _authHeaders() : {'Accept': 'application/json', 'Content-Type': 'application/json'};
    final uri = _buildUri(path);
    return await http.post(uri, headers: headers, body: body is String ? body : jsonEncode(body ?? {}));
  }

  // PUBLIC_INTERFACE
  Future<http.Response> patch(String path, {Object? body, bool auth = true}) async {
    /** Perform a PATCH request with optional JSON body. */
    final headers = auth ? await _authHeaders() : {'Accept': 'application/json', 'Content-Type': 'application/json'};
    final uri = _buildUri(path);
    return await http.patch(uri, headers: headers, body: body is String ? body : jsonEncode(body ?? {}));
  }

  // PUBLIC_INTERFACE
  Future<http.Response> delete(String path, {bool auth = true}) async {
    /** Perform a DELETE request. */
    final headers = auth ? await _authHeaders() : {'Accept': 'application/json'};
    final uri = _buildUri(path);
    return await http.delete(uri, headers: headers);
  }
}
