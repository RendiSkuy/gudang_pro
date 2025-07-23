import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'export_csv.dart';

import '../api/api_service.dart';
import '../models/barang_model.dart';

class BarangProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Barang> _allItems = []; // Menyimpan semua data asli
  List<Barang> _filteredItems = []; // Menyimpan data yang sudah difilter
  bool _isLoading = false;
  String? _errorMessage;
  String _currentSearch = '';
  String _currentKategori = '';
  bool _useClientSideFilter = true; // Flag untuk menggunakan client-side filtering

  List<Barang> get items => _filteredItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentSearch => _currentSearch;
  String get currentKategori => _currentKategori;

  BarangProvider() {
    fetchBarang();
  }

  Future<void> fetchBarang({String? kategori, String? search}) async {
    // Update current search state
    _currentSearch = search ?? '';
    _currentKategori = kategori ?? '';
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Fetching barang with search: "$search", kategori: "$kategori"');
      
      if (_useClientSideFilter) {
        // Jika menggunakan client-side filtering, selalu ambil semua data
        if (_allItems.isEmpty || search == null) {
          _allItems = await _apiService.getBarang();
          print('Loaded ${_allItems.length} items from server');
        }
        
        // Lakukan filtering di client side
        _performClientSideFiltering(search: search, kategori: kategori);
      } else {
        // Menggunakan server-side filtering
        _filteredItems = await _apiService.getBarang(kategori: kategori, search: search);
        _allItems = _filteredItems; // Sync dengan all items
      }
      
      print('Filtered to ${_filteredItems.length} items');
      
    } catch (e) {
      print('Error in fetchBarang: $e');
      _errorMessage = e.toString();
      _filteredItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _performClientSideFiltering({String? search, String? kategori}) {
    List<Barang> filtered = List.from(_allItems);
    
    // Filter berdasarkan kategori
    if (kategori != null && kategori.trim().isNotEmpty) {
      filtered = filtered.where((item) => 
        item.kategori.toLowerCase().contains(kategori.toLowerCase())
      ).toList();
    }
    
    // Filter berdasarkan search query
    if (search != null && search.trim().isNotEmpty) {
      String searchLower = search.toLowerCase().trim();
      filtered = filtered.where((item) {
        return item.namaBarang.toLowerCase().contains(searchLower) ||
               item.kategori.toLowerCase().contains(searchLower) ||
               item.satuan.toLowerCase().contains(searchLower);
      }).toList();
      
      print('Client-side search for "$search" found ${filtered.length} results');
    }
    
    _filteredItems = filtered;
  }

  // Method untuk toggle antara client-side dan server-side filtering
  void toggleFilterMode() {
    _useClientSideFilter = !_useClientSideFilter;
    print('Filter mode changed to: ${_useClientSideFilter ? "Client-side" : "Server-side"}');
    // Refresh dengan mode baru
    fetchBarang(search: _currentSearch.isEmpty ? null : _currentSearch, 
               kategori: _currentKategori.isEmpty ? null : _currentKategori);
  }

  // Method untuk force refresh dari server
  Future<void> forceRefreshFromServer() async {
    _allItems.clear();
    await fetchBarang(search: _currentSearch.isEmpty ? null : _currentSearch, 
                     kategori: _currentKategori.isEmpty ? null : _currentKategori);
  }

  Future<bool> addBarang(Map<String, dynamic> data) async {
    try {
      bool success = await _apiService.addBarang(data);
      if (success) {
        // Force refresh dari server untuk mendapatkan data terbaru
        await forceRefreshFromServer();
      }
      return success;
    } catch (e) {
      print('Error in addBarang: $e');
      return false;
    }
  }

  Future<bool> updateBarang(String id, Map<String, dynamic> data) async {
    try {
      bool success = await _apiService.updateBarang(id, data);
      if (success) {
        // Force refresh dari server untuk mendapatkan data terbaru
        await forceRefreshFromServer();
      }
      return success;
    } catch (e) {
      print('Error in updateBarang: $e');
      return false;
    }
  }

  Future<bool> deleteBarang(String id) async {
    try {
      bool success = await _apiService.deleteBarang(id);
      if (success) {
        // Remove dari both lists untuk immediate UI update
        _allItems.removeWhere((item) => item.id == id);
        _filteredItems.removeWhere((item) => item.id == id);
        notifyListeners();
        
        // Optional: refresh dari server untuk memastikan konsistensi
        // await forceRefreshFromServer();
      }
      return success;
    } catch (e) {
      print('Error in deleteBarang: $e');
      return false;
    }
  }

  // Clear search and show all items
  Future<void> clearSearch() async {
    _currentSearch = '';
    _currentKategori = '';
    if (_useClientSideFilter) {
      _performClientSideFiltering();
      notifyListeners();
    } else {
      await fetchBarang();
    }
  }

  // Refresh current view (with current search/filter)
  Future<void> refresh() async {
    await forceRefreshFromServer();
  }

  // Method untuk search langsung tanpa delay (untuk immediate feedback)
  void searchImmediate(String query) {
    if (_useClientSideFilter) {
      _currentSearch = query;
      _performClientSideFiltering(search: query, kategori: _currentKategori.isEmpty ? null : _currentKategori);
      notifyListeners();
    }
  }

  // Export function - menggunakan all items atau filtered items
  Future<String?> exportToCsv({bool exportFiltered = false}) async {
    List<Barang> itemsToExport = exportFiltered ? _filteredItems : _allItems;
    
    if (itemsToExport.isEmpty) {
      return exportFiltered ? "Tidak ada data hasil filter untuk di-export." : "Tidak ada data untuk di-export.";
    }

    List<List<dynamic>> rows = [];
    rows.add([
      "ID",
      "Nama Barang",
      "Kategori",
      "Jumlah Stok",
      "Satuan",
      "Tanggal Masuk"
    ]);

    for (var item in itemsToExport) {
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
    return await exportCsv(csv);
  }

  // Method untuk debugging
  void printCurrentState() {
    print('=== BARANG PROVIDER STATE ===');
    print('Filter Mode: ${_useClientSideFilter ? "Client-side" : "Server-side"}');
    print('Current Search: "$_currentSearch"');
    print('Current Kategori: "$_currentKategori"');
    print('All Items count: ${_allItems.length}');
    print('Filtered Items count: ${_filteredItems.length}');
    print('Is Loading: $_isLoading');
    print('Error: $_errorMessage');
    if (_filteredItems.isNotEmpty) {
      print('Sample filtered items:');
      for (int i = 0; i < (_filteredItems.length > 3 ? 3 : _filteredItems.length); i++) {
        print('  - ${_filteredItems[i].namaBarang}');
      }
    }
    print('=============================');
  }
}