import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart'; // Impor halaman login

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Fungsi untuk melakukan logout
  void _logout(BuildContext context) async {
    // 1. Inisialisasi storage
    const storage = FlutterSecureStorage();

    // 2. Hapus token dari secure storage
    await storage.delete(key: 'jwt_token');

    // 3. Pindah ke halaman login dan hapus semua halaman sebelumnya dari tumpukan navigasi
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Tema Aplikasi'),
            subtitle: const Text('Pilih mode terang atau gelap'),
            onTap: () {
              // Logika untuk mengubah tema bisa ditambahkan di sini
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Notifikasi Stok Kritis'),
            value: true, // Nilai ini bisa diambil dari state
            onChanged: (bool value) {
              // Logika untuk menyimpan pengaturan notifikasi
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('Versi 1.0.0'),
          ),
          const Divider(),

          // --- TOMBOL LOGOUT DITAMBAHKAN DI SINI ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _logout(context), // Memanggil fungsi logout saat diklik
          ),
        ],
      ),
    );
  }
}