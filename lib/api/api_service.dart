import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // <-- Impor package
import '../models/barang_model.dart';

class ApiService {
  // URL ini sudah benar, mengarah ke Cloudflare Tunnel Anda
  final String _baseUrl = "https://api.ovak.my.id/api/";
  
  // Instance untuk mengakses secure storage
  final _storage = const FlutterSecureStorage();

  // FUNGSI BARU: Helper untuk mendapatkan header dengan token
  Future<Map<String, String>> _getAuthHeaders() async {
    String? token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      return {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      };
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
    };
  }

  // --- FUNGSI LAMA YANG DISESUAIKAN ---

  Future<List<Barang>> getBarang({String? search, String? kategori}) async {
    var url = Uri.parse('${_baseUrl}barang');
    if (search != null && search.isNotEmpty) {
      url = url.replace(queryParameters: {'search': search});
    }
    
    // MODIFIKASI: Tambahkan header otentikasi
    final response = await http.get(url, headers: await _getAuthHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Barang.fromMap(item)).toList();
    } else {
      throw Exception('Gagal memuat data. Status: ${response.statusCode}');
    }
  }

  Future<bool> addBarang(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}barang'),
      headers: await _getAuthHeaders(), // <-- MODIFIKASI
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateBarang(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('${_baseUrl}barang/$id'),
      headers: await _getAuthHeaders(), // <-- MODIFIKASI
      body: jsonEncode(data),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteBarang(String id) async {
    final response = await http.delete(
      Uri.parse('${_baseUrl}barang/$id'),
      headers: await _getAuthHeaders(), // <-- MODIFIKASI
    );
    return response.statusCode == 200;
  }

  // --- FUNGSI BARU UNTUK LOGIN & REGISTRASI ---

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}auth/login'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login Gagal');
    }
  }

  Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}auth/register'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return response.statusCode == 201;
  }
}