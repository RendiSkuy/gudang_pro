import 'package:flutter/material.dart';
import 'package:gudang_pro/providers/auth_provider.dart';
import 'package:gudang_pro/screens/main_screen.dart';
import 'package:gudang_pro/screens/register_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Gagal! Username atau password salah.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Gudang Pro', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => value!.isEmpty ? 'Username tidak boleh kosong' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) => value!.isEmpty ? 'Password tidak boleh kosong' : null,
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(onPressed: _login, child: const Text('Login')),
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: const Text('Tidak punya akun? Daftar di sini'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}