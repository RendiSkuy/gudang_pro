import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/barang_provider.dart';
import 'add_edit_screen.dart';
import 'package:intl/intl.dart'; // <-- INI PERBAIKANNYA
import '../models/barang_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            title: Row(
              children: [
                Image.asset('assets/images/logo.png', height: 32),
                const SizedBox(width: 12),
                const Text('Gudang Pro'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.file_download_outlined),
                tooltip: 'Export ke CSV',
                onPressed: () async {
                  final provider =
                      Provider.of<BarangProvider>(context, listen: false);
                  final result = await provider.exportToCsv();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text(result ?? 'File CSV berhasil diexport.')),
                    );
                  }
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80.0), // <-- Ubah menjadi 80
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    16, 0, 16, 16), // Padding bawah disesuaikan
                child: TextField(
                  onChanged: (value) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        Provider.of<BarangProvider>(context, listen: false)
                            .fetchBarang(search: value);
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari barang...',
                    prefixIcon: Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: const TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Consumer<BarangProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.items.isEmpty) {
                return SliverFillRemaining(
                    hasScrollBody: false, child: _buildShimmerLoading());
              }
              if (provider.errorMessage != null) {
                return SliverFillRemaining(
                    hasScrollBody: false,
                    child:
                        Center(child: Text('Error: ${provider.errorMessage}')));
              }
              if (provider.items.isEmpty) {
                return SliverFillRemaining(
                    hasScrollBody: false, child: _buildEmptyState());
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = provider.items[index];
                    return _buildBarangListItem(item);
                  },
                  childCount: provider.items.length,
                ),
              );
            },
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

  Widget _buildBarangListItem(Barang item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Masuk: ${DateFormat('dd MMM yyyy').format(item.tanggalMasuk)}', // <-- Penggunaan DateFormat
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.primary,
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
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
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
              Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: double.infinity,
                        height: 16.0,
                        color: Colors.white),
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
          Icon(Icons.inventory_2_outlined,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          Text(
            'Inventaris Anda Kosong',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600),
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
