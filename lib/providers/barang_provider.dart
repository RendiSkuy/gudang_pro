import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'export_csv.dart';

import '../api/api_service.dart';
import '../models/barang_model.dart';

class BarangProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Barang> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<Barang> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BarangProvider() {
    fetchBarang();
  }

  Future<void> fetchBarang({String? kategori, String? search}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _apiService.getBarang(kategori: kategori, search: search);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBarang(Map<String, dynamic> data) async {
    bool success = await _apiService.addBarang(data);
    if (success) {
      fetchBarang();
    }
    return success;
  }

  Future<bool> updateBarang(String id, Map<String, dynamic> data) async {
    bool success = await _apiService.updateBarang(id, data);
    if (success) {
      fetchBarang();
    }
    return success;
  }

  Future<void> deleteBarang(String id) async {
    await _apiService.deleteBarang(id);
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // --- FUNGSI EXPORT YANG SUDAH DIPERBARUI ---
  Future<String?> exportToCsv() async {
    if (_items.isEmpty) return "Tidak ada data untuk di-export.";

    List<List<dynamic>> rows = [];
    rows.add([
      "ID",
      "Nama Barang",
      "Kategori",
      "Jumlah Stok",
      "Satuan",
      "Tanggal Masuk"
    ]);

    for (var item in _items) {
      rows.add([
        item.id,
        item.namaBarang,
        item.kategori,
        item.jumlahStok,
        item.satuan,
        item.tanggalMasuk.toIso8601String().substring(0, 10)
      ]);
    }

    String csv = const ListToCsvConverter(fieldDelimiter: ';').convert(rows);

    // Gunakan fungsi export sesuai platform
    return await exportCsv(csv);
  }
}
