import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/barang_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Palet Warna Baru
    const Color primaryColor = Color(0xFF00897B); // Teal yang lebih gelap
    const Color lightGrey = Color(0xFFF5F5F5); // Abu-abu sangat terang

    return ChangeNotifierProvider(
      create: (context) => BarangProvider(),
      child: MaterialApp(
        title: 'Gudang Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Skema Warna
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
            background: lightGrey,
          ),
          useMaterial3: true,

          // Tema Latar Belakang
          scaffoldBackgroundColor: lightGrey,

          // Tema AppBar
          appBarTheme: const AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 1,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          // Tema Floating Action Button
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),

          // Tema Tombol
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Tema Input Form
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            floatingLabelStyle: const TextStyle(color: primaryColor),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}