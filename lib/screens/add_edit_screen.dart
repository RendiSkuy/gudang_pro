import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/barang_model.dart';
import '../providers/barang_provider.dart';
import 'package:intl/intl.dart';

class AddEditScreen extends StatefulWidget {
  final Barang? barang;
  const AddEditScreen({super.key, this.barang});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _namaBarang;
  late String _kategori;
  late int _jumlahStok;
  late String _satuan;
  late DateTime _tanggalMasuk;

  final TextEditingController _tanggalController = TextEditingController();

  final List<String> _kategoriOptions = [
    'Elektronik',
    'ATK',
    'Perkakas',
    'Pakaian',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.barang != null) {
      _namaBarang = widget.barang!.namaBarang;
      _kategori = widget.barang!.kategori;
      _jumlahStok = widget.barang!.jumlahStok;
      _satuan = widget.barang!.satuan;
      _tanggalMasuk = widget.barang!.tanggalMasuk;
    } else {
      _namaBarang = '';
      _kategori = _kategoriOptions[0];
      _jumlahStok = 0;
      _satuan = 'pcs';
      _tanggalMasuk = DateTime.now();
    }
    _tanggalController.text = DateFormat('yyyy-MM-dd').format(_tanggalMasuk);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMasuk,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _tanggalMasuk) {
      setState(() {
        _tanggalMasuk = picked;
        _tanggalController.text = DateFormat('yyyy-MM-dd').format(_tanggalMasuk);
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<BarangProvider>(context, listen: false);

      final data = {
        'nama_barang': _namaBarang,
        'kategori': _kategori,
        'jumlah_stok': _jumlahStok,
        'satuan': _satuan,
        'tanggal_masuk': _tanggalMasuk.toIso8601String(), // Kirim dalam format ISO
      };

      bool success;
      if (widget.barang == null) {
        success = await provider.addBarang(data);
      } else {
        // Pastikan widget.barang!.id (yang sekarang String) dipassing
        success = await provider.updateBarang(widget.barang!.id, data);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil disimpan!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OPERASI GAGAL! Periksa koneksi atau data input Anda.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _deleteBarang() async {
    if (widget.barang != null) {
      final provider = Provider.of<BarangProvider>(context, listen: false);
      // Pastikan widget.barang!.id (yang sekarang String) dipassing
      await provider.deleteBarang(widget.barang!.id);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil dihapus!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.barang == null ? 'Tambah Barang' : 'Edit Barang'),
        elevation: 1,
        actions: [
          if (widget.barang != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Konfirmasi Hapus'),
                    content: const Text('Anda yakin ingin menghapus barang ini?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Batal')),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _deleteBarang();
                        },
                        child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _namaBarang,
                decoration: const InputDecoration(labelText: 'Nama Barang', prefixIcon: Icon(Icons.inventory_2)),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Nama barang tidak boleh kosong' : null,
                onSaved: (value) => _namaBarang = value!,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _kategoriOptions.contains(_kategori) ? _kategori : _kategoriOptions.last,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _kategoriOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _kategori = newValue!;
                  });
                },
                onSaved: (value) => _kategori = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _jumlahStok.toString(),
                decoration: const InputDecoration(
                    labelText: 'Jumlah Stok',
                    prefixIcon: Icon(Icons.format_list_numbered)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Jumlah stok tidak boleh kosong';
                  if (int.tryParse(value) == null)
                    return 'Masukkan angka yang valid';
                  return null;
                },
                onSaved: (value) => _jumlahStok = int.parse(value!),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: _satuan,
                decoration: const InputDecoration(
                    labelText: 'Satuan (e.g., pcs, kg, unit)',
                    prefixIcon: Icon(Icons.ad_units)),
                validator: (value) =>
                    value!.trim().isEmpty ? 'Satuan tidak boleh kosong' : null,
                onSaved: (value) => _satuan = value!,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _tanggalController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Masuk',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Simpan Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}