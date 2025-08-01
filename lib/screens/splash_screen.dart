import 'package:flutter/material.dart';
import 'package:gudang_pro/providers/auth_provider.dart';
import 'package:gudang_pro/screens/login_screen.dart';
import 'package:gudang_pro/screens/main_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 1)); 
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();
    
    if (!mounted) return;

    if (authProvider.isLoggedIn) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}