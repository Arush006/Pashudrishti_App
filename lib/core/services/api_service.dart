import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000';
    }

    return 'http://127.0.0.1:5000';
  }

  static Map<String, String> authHeaders(String? token) => {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  static String _normalizeRole(String? role) {
    final value = (role ?? '').trim().toLowerCase();
    if (value == 'veterinarian' || value == 'doctor') return 'doctor';
    return 'user';
  }

  static String _uiRoleFromServer(String? role) {
    final value = (role ?? '').trim().toLowerCase();
    if (value == 'doctor' || value == 'veterinarian') return 'Veterinarian';
    return 'Livestock Owner';
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['error'] ?? 'Login failed');
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String phone = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim(),
        'password': password,
        'role': _normalizeRole(role),
        'phone': phone.trim(),
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['error'] ?? 'Registration failed');
  }

  static Future<Map<String, dynamic>> getUserDashboard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user/dashboard'),
      headers: authHeaders(token),
    );

    return _handleJson(response, 'Failed to fetch dashboard');
  }

  static Future<List<dynamic>> getMyCases(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user/cases'),
      headers: authHeaders(token),
    );

    final decoded = _handleJson(response, 'Failed to fetch cases');
    return decoded is List ? decoded : (decoded['data'] is List ? decoded['data'] : const []);
  }

  static Future<List<dynamic>> getNearbyDoctors(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user/doctors'),
      headers: authHeaders(token),
    );

    final decoded = _handleJson(response, 'Failed to fetch doctors');
    return decoded is List ? decoded : (decoded['data'] is List ? decoded['data'] : const []);
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/user/profile'),
      headers: authHeaders(token),
    );

    return _handleJson(response, 'Failed to fetch profile');
  }

  static Future<Map<String, dynamic>> updateProfile(String token, {
    required String name,
    required String phone,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/user/profile'),
      headers: authHeaders(token),
      body: jsonEncode({
        'name': name.trim(),
        'phone': phone.trim(),
      }),
    );

    return _handleJson(response, 'Failed to update profile');
  }

  static Future<Map<String, dynamic>> submitCase(String token, Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/user/cases'),
      headers: authHeaders(token),
      body: jsonEncode(payload),
    );

    return _handleJson(response, 'Failed to submit case');
  }

  static Future<Map<String, dynamic>> getDoctorDashboard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/doctor/dashboard'),
      headers: authHeaders(token),
    );

    return _handleJson(response, 'Failed to fetch doctor dashboard');
  }

  static Future<List<dynamic>> getDoctorCases(String token, {String? search}) async {
    final uri = search == null || search.isEmpty
        ? Uri.parse('$baseUrl/api/doctor/cases')
        : Uri.parse('$baseUrl/api/doctor/cases?search=${Uri.encodeComponent(search)}');

    final response = await http.get(uri, headers: authHeaders(token));
    final decoded = _handleJson(response, 'Failed to fetch doctor cases');
    return decoded is List ? decoded : (decoded['data'] is List ? decoded['data'] : const []);
  }

  static Future<Map<String, dynamic>> getDiseases(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ai/diseases'),
      headers: authHeaders(token),
    );

    return _handleJson(response, 'Failed to fetch diseases');
  }

  static Future<Map<String, dynamic>> predictDisease(String token, Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ai/predict-disease'),
      headers: authHeaders(token),
      body: jsonEncode(payload),
    );

    return _handleJson(response, 'Failed to predict disease');
  }

  static String roleForUi(String? role) => _uiRoleFromServer(role);

  static Map<String, dynamic> _handleJson(http.Response response, String fallbackMessage) {
    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return {'data': decoded};
    }

    final message = decoded is Map && decoded['error'] != null ? decoded['error'] : fallbackMessage;
    throw Exception(message);
  }
}
