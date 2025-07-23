import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/barang_model.dart';

class ApiService {
  // URL ini sudah benar, mengarah ke Cloudflare Tunnel Anda
  final String _baseUrl = "https://api.ovak.my.id/api/";
  
  // Instance untuk mengakses secure storage
  final _storage = const FlutterSecureStorage();

  // Helper untuk mendapatkan header dengan token
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

  Future<List<Barang>> getBarang({String? search, String? kategori}) async {
    // Mulai dengan base URL
    String urlString = '${_baseUrl}barang';
    
    // Siapkan parameter query
    Map<String, String> queryParams = {};
    
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    
    if (kategori != null && kategori.trim().isNotEmpty) {
      queryParams['kategori'] = kategori.trim();
    }
    
    // Build URI dengan query parameters
    Uri url = Uri.parse(urlString);
    if (queryParams.isNotEmpty) {
      url = url.replace(queryParameters: queryParams);
    }
    
    print('🔍 API URL: $url');
    
    try {
      final response = await http.get(url, headers: await _getAuthHeaders());
      
      print('📡 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        // Handle different response formats
        List<dynamic> data;
        if (responseData is Map<String, dynamic>) {
          // Jika response dalam format { "data": [...], "message": "...", etc }
          if (responseData.containsKey('data')) {
            data = responseData['data'] as List<dynamic>;
          } else if (responseData.containsKey('items')) {
            data = responseData['items'] as List<dynamic>;
          } else if (responseData.containsKey('barang')) {
            data = responseData['barang'] as List<dynamic>;
          } else {
            // Jika response map tapi tidak ada key yang dikenal, coba ambil semua values yang berupa array
            var arrayValues = responseData.values.where((v) => v is List).toList();
            if (arrayValues.isNotEmpty) {
              data = arrayValues.first as List<dynamic>;
            } else {
              throw Exception('Format response tidak sesuai: ${responseData.keys}');
            }
          }
        } else if (responseData is List<dynamic>) {
          // Jika response langsung berupa array
          data = responseData;
        } else {
          throw Exception('Format response tidak dikenal: ${responseData.runtimeType}');
        }
        
        print('✅ Parsed ${data.length} items from response');
        
        final items = data.map((item) => Barang.fromMap(item)).toList();
        
        // Debug: print sample items
        if (items.isNotEmpty) {
          print('📋 Sample items:');
          for (int i = 0; i < (items.length > 3 ? 3 : items.length); i++) {
            print('   ${i + 1}. ${items[i].namaBarang}');
          }
        }
        
        return items;
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error dalam getBarang: $e');
      rethrow; // Re-throw untuk handling di provider
    }
  }

  Future<bool> addBarang(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}barang'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(data),
      );
      
      print('Add Barang Status: ${response.statusCode}');
      print('Add Barang Response: ${response.body}');
      
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error dalam addBarang: $e');
      return false;
    }
  }

  Future<bool> updateBarang(String id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${_baseUrl}barang/$id'),
        headers: await _getAuthHeaders(),
        body: jsonEncode(data),
      );
      
      print('Update Barang Status: ${response.statusCode}');
      print('Update Barang Response: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error dalam updateBarang: $e');
      return false;
    }
  }

  Future<bool> deleteBarang(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${_baseUrl}barang/$id'),
        headers: await _getAuthHeaders(),
      );
      
      print('Delete Barang Status: ${response.statusCode}');
      print('Delete Barang Response: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error dalam deleteBarang: $e');
      return false;
    }
  }

  // Fungsi untuk login
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      
      print('Login Status: ${response.statusCode}');
      print('Login Response: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login gagal: ${response.body}');
      }
    } catch (e) {
      print('Error dalam login: $e');
      throw Exception('Login gagal: $e');
    }
  }

  // Fungsi untuk registrasi
  Future<bool> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${_baseUrl}auth/register'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      
      print('Register Status: ${response.statusCode}');
      print('Register Response: ${response.body}');
      
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error dalam register: $e');
      return false;
    }
  }
}