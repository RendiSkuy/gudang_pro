import 'package:flutter/material.dart';
import 'package:gudang_pro/api/api_service.dart'; // <-- PERBAIKAN DI SINI
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Transaksi'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Barang Masuk'),
            Tab(text: 'Barang Keluar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransactionList('masuk'),
          _buildTransactionList('keluar'),
        ],
      ),
    );
  }

  Widget _buildTransactionList(String tipe) {
    return FutureBuilder<List<dynamic>>(
      key: PageStorageKey(tipe), 
      future: _apiService.getTransactions(tipe),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada data transaksi.'));
        }
        final transactions = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => setState((){}),
          child: ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final trx = transactions[index];
              final barang = trx['id_barang'];
              final tanggal = DateFormat('d MMM yyyy, HH:mm').format(DateTime.parse(trx['tanggal']));
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(barang?['nama_barang'] ?? 'Barang Dihapus'),
                  subtitle: Text('Jumlah: ${trx['jumlah']} | Tanggal: $tanggal'),
                  trailing: Text('Stok Akhir: ${trx['stok_akhir']}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}