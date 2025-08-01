import 'package:flutter/material.dart';
import 'package:gudang_pro/providers/auth_provider.dart';
import 'package:gudang_pro/providers/barang_provider.dart';
import 'package:gudang_pro/screens/splash_screen.dart';
import 'package:provider/provider.dart'; // <-- PERBAIKAN DI SINI

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF00897B);
    const Color lightGrey = Color(0xFFF5F5F5);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BarangProvider()),
      ],
      child: MaterialApp(
        title: 'Gudang Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryColor,
            primary: primaryColor,
            background: lightGrey,
          ),
          scaffoldBackgroundColor: lightGrey,
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
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
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
        home: const SplashScreen(),
      ),
    );
  }
}