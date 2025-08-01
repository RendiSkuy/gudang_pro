import 'package:flutter/material.dart';
import 'package:gudang_pro/models/barang_model.dart';
import 'package:gudang_pro/providers/auth_provider.dart';
import 'package:gudang_pro/providers/barang_provider.dart';
import 'package:gudang_pro/screens/add_edit_screen.dart';
import 'package:gudang_pro/screens/login_screen.dart';
import 'package:provider/provider.dart';

class InventarisScreen extends StatefulWidget {
  const InventarisScreen({super.key});

  @override
  State<InventarisScreen> createState() => _InventarisScreenState();
}

class _InventarisScreenState extends State<InventarisScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BarangProvider>(context, listen: false).fetchBarang();
    });
  }

  void _navigateToAddEditScreen({Barang? barang}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditScreen(barang: barang),
      ),
    ).then((isSaved) {
      if (isSaved == true) {
        Provider.of<BarangProvider>(context, listen: false).fetchBarang();
      }
    });
  }
  
  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final barangProvider = Provider.of<BarangProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventaris Barang'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Cari Nama Barang...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                Provider.of<BarangProvider>(context, listen: false).search(value);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'active', label: Text('Aktif')),
                ButtonSegment(value: 'inactive', label: Text('Tidak Aktif')),
                ButtonSegment(value: 'all', label: Text('Semua')),
              ],
              selected: {barangProvider.statusFilter},
              onSelectionChanged: (newSelection) {
                barangProvider.setFilter(newSelection.first);
              },
            ),
          ),
          Expanded(
            child: Consumer<BarangProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.items.isEmpty) {
                  return const Center(child: Text('Barang tidak ditemukan.'));
                }
                return RefreshIndicator(
                  onRefresh: () => provider.fetchBarang(),
                  child: ListView.builder(
                    itemCount: provider.items.length,
                    itemBuilder: (context, index) {
                      final barang = provider.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(barang.namaBarang),
                          subtitle: Text(barang.kategori),
                          trailing: Text('${barang.jumlahStok} ${barang.satuan}'),
                          onTap: () => _navigateToAddEditScreen(barang: barang),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}