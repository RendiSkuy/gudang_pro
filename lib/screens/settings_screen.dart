import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              // Logika untuk mengubah tema
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
            onTap: () {},
          ),
        ],
      ),
    );
  }
}