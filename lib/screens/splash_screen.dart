import 'dart:async';
import 'package:flutter/material.dart';
import 'main_screen.dart'; // Halaman utama kita

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Jalankan fungsi navigasi setelah beberapa detik
    Timer(const Duration(seconds: 3), () {
      // Pindah ke halaman utama dan hapus splash screen dari tumpukan navigasi
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gunakan warna tema utama sebagai latar belakang
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tampilkan logo Anda
            Image.asset(
              'assets/images/logo.png',
              width: 150, // Atur ukuran logo
            ),
            const SizedBox(height: 24),
            // Indikator loading
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}