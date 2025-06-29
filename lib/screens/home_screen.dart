import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/barang_provider.dart';
import 'add_edit_screen.dart';
import 'package:intl/intl.dart';
import '../models/barang_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Semua fungsi helper (seperti _getIconForCategory) dan state management tetap sama.
  // ... (semua fungsi initState, dispose, dan _onSearchChanged dari kode sebelumnya tetap di sini)
    @override
  void initState() {
    super.initState();
    Provider.of<BarangProvider>(context, listen: false).fetchBarang();
  }

  IconData _getIconForCategory(String category) {
    if (category.toLowerCase().contains('elektronik')) return Icons.computer;
    if (category.toLowerCase().contains('atk')) return Icons.edit_note;
    if (category.toLowerCase().contains('perkakas')) return Icons.construction;
    if (category.toLowerCase().contains('pakaian')) return Icons.checkroom;
    return Icons.inventory_2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar sekarang menggunakan tema dari main.dart
      appBar: AppBar(
        title: const Text('Gudang Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export ke CSV',
            onPressed: () async {
              // Fungsi export tidak berubah
              final provider = Provider.of<BarangProvider>(context, listen: false);
              final result = await provider.exportToCsv();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result ?? 'File CSV berhasil diexport.')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Widget Pencarian
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                // Fungsi pencarian tidak berubah
                 Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      Provider.of<BarangProvider>(context, listen: false)
                          .fetchBarang(search: value);
                    }
                  });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama atau kategori barang...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          // Daftar Barang
          Expanded(
            child: Consumer<BarangProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.items.isEmpty) {
                  return _buildShimmerLoading();
                }
                if (provider.errorMessage != null) {
                  return Center(child: Text('Error: ${provider.errorMessage}'));
                }
                if (provider.items.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: () => provider.fetchBarang(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    itemCount: provider.items.length,
                    itemBuilder: (context, index) {
                      final item = provider.items[index];
                      // Panggil widget desain baru
                      return _buildBarangListItem(item, provider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditScreen()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Barang',
      ),
    );
  }

  // --- WIDGET DESAIN BARU UNTUK LIST ITEM ---
  Widget _buildBarangListItem(Barang item, BarangProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditScreen(barang: item),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForCategory(item.kategori),
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.namaBarang,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.kategori,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.jumlahStok.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Color(0xFF00897B), // Warna utama
                  ),
                ),
                Text(
                  item.satuan,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    // Efek shimmer disesuaikan dengan layout baru
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Row(
            children: [
              Container(width: 54, height: 54, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 16.0, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 100.0, height: 12.0, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
      return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'Inventaris Anda Kosong',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          Text(
            'Klik tombol + untuk menambah barang baru.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}