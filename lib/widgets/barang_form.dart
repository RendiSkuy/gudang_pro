import 'package:flutter/material.dart';
import 'package:gudang_pro/models/barang_model.dart';
import 'package:gudang_pro/providers/barang_provider.dart';
import 'package:provider/provider.dart';

class BarangForm extends StatefulWidget {
  final Barang? barang;
  const BarangForm({super.key, this.barang});

  @override
  State<BarangForm> createState() => _BarangFormState();
}

class _BarangFormState extends State<BarangForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _stokController;
  
  String? _kategori;
  String? _satuan;
  bool _isActive = true;
  bool _isLoading = false;

  final List<String> _kategoriOptions = ['Elektronik', 'ATK', 'Pakaian', 'Perkakas', 'Lainnya'];
  final List<String> _satuanOptions = ['Pcs', 'Unit', 'Botol', 'Box', 'Lusin'];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.barang?.namaBarang ?? '');
    _stokController = TextEditingController(text: widget.barang?.jumlahStok.toString() ?? '0');
    _kategori = widget.barang?.kategori ?? 'Lainnya';
    _satuan = widget.barang?.satuan ?? 'Pcs';
    _isActive = widget.barang?.isActive ?? true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    
    final newBarangData = Barang(
      id: widget.barang?.id,
      namaBarang: _namaController.text,
      kategori: _kategori!,
      jumlahStok: int.parse(_stokController.text),
      satuan: _satuan!,
      isActive: _isActive,
    );

    try {
      if (widget.barang == null) {
        await barangProvider.addBarang(newBarangData);
      } else {
        // Pastikan widget.barang.id tidak null
        await barangProvider.updateBarang(widget.barang!.id!, newBarangData);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')),
        );
      }
    } finally {
       if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Barang'),
              validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategori,
              items: _kategoriOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _kategori = val),
              decoration: const InputDecoration(labelText: 'Kategori'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stokController,
              decoration: const InputDecoration(labelText: 'Jumlah Stok'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? 'Stok tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _satuan,
              items: _satuanOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => _satuan = val),
              decoration: const InputDecoration(labelText: 'Satuan'),
            ),
            if (widget.barang != null)
              SwitchListTile(
                title: const Text('Barang Aktif'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
                contentPadding: EdgeInsets.zero,
              ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _submitForm, child: const Text('Simpan'))
                  ),
          ],
        ),
      ),
    );
  }
}