import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/barang_provider.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data dari provider
    final provider = context.watch<BarangProvider>();
    final totalJenis = provider.items.length;
    final totalStok = provider.items.fold(0, (sum, item) => sum + item.jumlahStok);
    final stokKritis = provider.items.where((item) => item.jumlahStok < 10).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Inventaris'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Baris untuk Kartu Ringkasan
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Total Jenis', totalJenis.toString(), Icons.inventory_2, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildSummaryCard('Total Stok', totalStok.toString(), Icons.stacked_bar_chart, Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),

          // Placeholder untuk Grafik
          Text('Distribusi Kategori', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
            ),
            child: const Center(child: Text('Tempat untuk Pie Chart nanti')),
          ),
          const SizedBox(height: 24),
          
          // Daftar Stok Kritis
          Text('Stok Kritis (${stokKritis.length} Barang)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          // Jika tidak ada stok kritis
          if (stokKritis.isEmpty)
            const Text('Tidak ada barang dengan stok kritis.'),
          // Jika ada, tampilkan sebagai list
          ...stokKritis.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade800,
                child: const Icon(Icons.warning_amber_rounded),
              ),
              title: Text(item.namaBarang),
              trailing: Text('${item.jumlahStok} ${item.satuan}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )),
        ],
      ),
    );
  }

  // Helper widget untuk membuat kartu ringkasan
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 14, color: color)),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}