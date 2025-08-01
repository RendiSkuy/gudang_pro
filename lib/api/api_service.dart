import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Gunakan localhost untuk build Windows/Web/iOS Simulator
  final String _baseUrl = "http://localhost:8080/api";
  // Gunakan 10.0.2.2 hanya untuk Emulator Android
  // final String _baseUrl = "http://10.0.2.2:8080/api";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return response.statusCode == 201;
  }

  Future<List<dynamic>> getBarang(String status, String search) async {
    final queryParams = {
      'status': status,
      if (search.isNotEmpty) 'search': search,
    };
    final uri = Uri.parse('$_baseUrl/barang').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data barang');
    }
  }

  Future<void> createBarang(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/barang'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode != 201) throw Exception('Gagal membuat barang');
  }

  Future<void> updateBarang(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/barang/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) throw Exception('Gagal update barang');
  }

  Future<List<dynamic>> getTransactions(String tipe) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/transactions?tipe=$tipe'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Gagal memuat laporan');
  }
}