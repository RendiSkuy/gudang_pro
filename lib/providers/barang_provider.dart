import 'dart:async'; // Diperlukan untuk Timer (debounce)
import 'package:flutter/material.dart';
import 'package:gudang_pro/models/barang_model.dart';
import 'package:gudang_pro/api/api_service.dart';

class BarangProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Barang> _items = [];
  bool _isLoading = false;
  String _statusFilter = 'active';
  String _searchTerm = '';
  Timer? _debounce;

  List<Barang> get items => _items;
  bool get isLoading => _isLoading;
  String get statusFilter => _statusFilter;

  // Method utama untuk mengambil data, sekarang selalu menggunakan state terbaru
  Future<void> fetchBarang() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _apiService.getBarang(_statusFilter, _searchTerm);
      _items = data.map((item) => Barang.fromJson(item)).toList();
    } catch (e) {
      print("Error fetching barang: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method untuk filter status
  void setFilter(String newStatus) {
    if (_statusFilter != newStatus) {
      _statusFilter = newStatus;
      fetchBarang(); 
    }
  }

  // Method untuk menangani input pencarian dengan debounce
  void search(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchTerm = query;
      fetchBarang();
    });
  }

  Future<void> addBarang(Barang barang) async {
    await _apiService.createBarang(barang.toJson());
    _searchTerm = ''; // Reset pencarian setelah menambah barang
    setFilter('active'); 
  }

  Future<void> updateBarang(String id, Barang barang) async {
    await _apiService.updateBarang(id, barang.toJson());
    fetchBarang(); 
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}