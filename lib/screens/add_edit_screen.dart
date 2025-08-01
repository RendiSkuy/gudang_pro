import 'package:flutter/material.dart';
import 'package:gudang_pro/models/barang_model.dart';
import 'package:gudang_pro/widgets/barang_form.dart';

class AddEditScreen extends StatelessWidget {
  final Barang? barang;
  const AddEditScreen({super.key, this.barang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(barang == null ? 'Tambah Barang' : 'Edit Barang'),
      ),
      body: BarangForm(barang: barang),
    );
  }
}