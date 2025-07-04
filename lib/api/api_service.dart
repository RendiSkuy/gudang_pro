import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barang_model.dart';

class ApiService {
  // --- SESUAIKAN ALAMAT INI ---
  // Untuk menjalankan di Web Browser: "http://localhost:8080/api/"
  // Untuk menjalankan di Emulator Android: "http://10.0.2.2:8080/api/"
  // Untuk menjalankan di HP Fisik: "http://<IP_LAPTOP_ANDA>:8080/api/"
  final String _baseUrl = "https://api.ovak.my.id/api/";

  Future<List<Barang>> getBarang({String? kategori, String? search}) async {
    var url = Uri.parse('${_baseUrl}barang');
    Map<String, String> queryParams = {};

    if (kategori != null && kategori.isNotEmpty) {
      queryParams['kategori'] = kategori;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (queryParams.isNotEmpty) {
      url = url.replace(queryParameters: queryParams);
    }
    
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return barangFromJson(response.body);
    } else {
      throw Exception('Gagal memuat data barang. Status code: ${response.statusCode}');
    }
  }

  Future<bool> addBarang(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}barang'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    return response.statusCode == 201;
  }

Future<bool> updateBarang(String id, Map<String, dynamic> data) async {
  final response = await http.put(
    Uri.parse('${_baseUrl}barang/$id'),
    headers: {'Content-Type': 'application/json; charset=UTF-8'},
    body: jsonEncode(data),
  );
  return response.statusCode == 200;
}

Future<bool> deleteBarang(String id) async {
  final response = await http.delete(Uri.parse('${_baseUrl}barang/$id'));
  return response.statusCode == 200;
}
}