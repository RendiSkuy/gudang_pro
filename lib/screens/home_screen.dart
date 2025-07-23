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
  final TextEditingController _searchController = TextEditingController();
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    Provider.of<BarangProvider>(context, listen: false).fetchBarang();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIconForCategory(String category) {
    if (category.toLowerCase().contains('elektronik')) return Icons.computer;
    if (category.toLowerCase().contains('atk')) return Icons.edit_note;
    if (category.toLowerCase().contains('perkakas')) return Icons.construction;
    if (category.toLowerCase().contains('pakaian')) return Icons.checkroom;
    return Icons.inventory_2;
  }

  void _performSearch(String query) {
    if (_currentSearchQuery != query) {
      _currentSearchQuery = query;
      final provider = Provider.of<BarangProvider>(context, listen: false);
      
      if (query.trim().isEmpty) {
        // Jika pencarian kosong, clear search
        provider.clearSearch();
      } else {
        // Gunakan immediate search untuk client-side filtering (lebih responsif)
        provider.searchImmediate(query.trim());
      }
    }
  }

  void _performDelayedSearch(String query) {
    // Untuk server-side search dengan delay
    if (_currentSearchQuery != query) {
      _currentSearchQuery = query;
      final provider = Provider.of<BarangProvider>(context, listen: false);
      
      if (query.trim().isEmpty) {
        provider.clearSearch();
      } else {
        provider.fetchBarang(search: query.trim());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              
              // Dialog untuk memilih export semua atau hanya hasil filter
              if (_currentSearchQuery.isNotEmpty) {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Export Data'),
                    content: const Text('Pilih data yang ingin di-export:'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Semua Data'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Hasil Pencarian'),
                      ),
                    ],
                  ),
                );
                
                if (result != null) {
                  final exportResult = await provider.exportToCsv(exportFiltered: result);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(exportResult ?? 'File CSV berhasil diexport.')),
                    );
                  }
                }
              } else {
                final result = await provider.exportToCsv();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result ?? 'File CSV berhasil diexport.')),
                  );
                }
              }
            },
          ),
          // Tombol untuk toggle filter mode (untuk debugging/testing)
          PopupMenuButton<String>(
            onSelected: (value) async {
              final provider = Provider.of<BarangProvider>(context, listen: false);
              switch (value) {
                case 'toggle_filter':
                  provider.toggleFilterMode();
                  break;
                case 'debug_state':
                  provider.printCurrentState();
                  break;
                case 'force_refresh':
                  await provider.forceRefreshFromServer();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'toggle_filter',
                child: Text('Toggle Filter Mode'),
              ),
              const PopupMenuItem(
                value: 'debug_state',
                child: Text('Debug State'),
              ),
              const PopupMenuItem(
                value: 'force_refresh',
                child: Text('Force Refresh'),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Immediate search untuk client-side filtering
                _performSearch(value);
                
                // Juga lakukan delayed search untuk server-side sebagai backup
                Future.delayed(const Duration(milliseconds: 1000), () {
                  if (mounted && _searchController.text == value) {
                    _performDelayedSearch(value);
                  }
                });
              },
              onSubmitted: (value) {
                // Langsung search ketika user tekan enter
                _performSearch(value);
              },
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                prefixIcon:
                    Icon(Icons.search, color: Theme.of(context).primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<BarangProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildShimmerLoading();
          }
          if (provider.errorMessage != null) {
            return _buildErrorState(provider.errorMessage!, provider);
          }
          if (provider.items.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80.0),
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                final item = provider.items[index];
                return _buildBarangListItem(item);
              },
            ),
          );
        },
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
                      'Masuk: ${DateFormat('dd MMM yyyy').format(item.tanggalMasuk)}',
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
                    Container(
                        width: 100.0, height: 12.0, color: Colors.white),
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
            _currentSearchQuery.isEmpty 
                ? 'Inventaris Anda Kosong'
                : 'Tidak ada hasil untuk "${_currentSearchQuery}"',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          Text(
            _currentSearchQuery.isEmpty
                ? 'Klik tombol + untuk menambah barang baru.'
                : 'Coba kata kunci yang berbeda atau tambah barang baru.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
          if (_currentSearchQuery.isNotEmpty) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
              child: const Text('Tampilkan Semua'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, BarangProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 20),
          Text(
            'Terjadi Kesalahan',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600),
          ),
          const SizedBox(height: 10),
          Text(
            error,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => provider.fetchBarang(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}