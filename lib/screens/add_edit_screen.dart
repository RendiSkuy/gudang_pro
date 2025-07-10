import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/barang_model.dart';
import '../providers/barang_provider.dart';
import 'login_screen.dart';

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

  final List<String> _kategoriOptions = ['Elektronik', 'ATK', 'Perkakas', 'Pakaian', 'Lainnya'];
  final List<String> _satuanOptions = ['Unit', 'Botol', 'Pcs', 'Rim', 'Set', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    if (widget.barang != null) {
      // Mode Edit
      _namaBarang = widget.barang!.namaBarang;
      _kategori = widget.barang!.kategori;
      _jumlahStok = widget.barang!.jumlahStok;
      _satuan = widget.barang!.satuan;
      _tanggalMasuk = widget.barang!.tanggalMasuk;
    } else {
      // Mode Tambah Baru
      _namaBarang = '';
      _kategori = _kategoriOptions[0];
      _jumlahStok = 0;
      _satuan = _satuanOptions[0];
      _tanggalMasuk = DateTime.now();
    }
  }

  // Fungsi untuk menampilkan pemilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMasuk,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _tanggalMasuk) {
      setState(() {
        _tanggalMasuk = picked;
      });
    }
  }

  // Fungsi untuk submit form (Create atau Update)
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<BarangProvider>(context, listen: false);

      final data = {
        'nama_barang': _namaBarang,
        'kategori': _kategori,
        'jumlah_stok': _jumlahStok,
        'satuan': _satuan,
        'tanggal_masuk': _tanggalMasuk.toIso8601String(),
      };

      bool success;
      if (widget.barang == null) {
        success = await provider.addBarang(data);
      } else {
        success = await provider.updateBarang(widget.barang!.id, data);
      }

      if (mounted && success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil disimpan!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operasi gagal!'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Fungsi untuk menghapus data
  void _deleteBarang() async {
    if (widget.barang != null) {
      final provider = Provider.of<BarangProvider>(context, listen: false);
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

  // Fungsi untuk menampilkan dialog konfirmasi hapus
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Anda yakin ingin menghapus barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
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
  }

  @override
  Widget build(BuildContext context) {
    String findDropdownValue(String value, List<String> options) {
      return options.firstWhere(
        (option) => option.toLowerCase() == value.toLowerCase(),
        orElse: () => options[0],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.barang == null ? 'Tambah Barang' : 'Edit Barang'),
        actions: [
          // Tombol Hapus hanya muncul saat mode edit
          if (widget.barang != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus Barang',
              onPressed: _showDeleteConfirmationDialog,
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _namaBarang,
                  decoration: const InputDecoration(labelText: 'Nama Barang', prefixIcon: Icon(Icons.inventory_2)),
                  validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  onSaved: (value) => _namaBarang = value!,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: findDropdownValue(_kategori, _kategoriOptions),
                  decoration: const InputDecoration(labelText: 'Kategori', prefixIcon: Icon(Icons.category)),
                  items: _kategoriOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                  onChanged: (newValue) => setState(() => _kategori = newValue!),
                  onSaved: (value) => _kategori = value!,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: _jumlahStok.toString(),
                  decoration: const InputDecoration(labelText: 'Jumlah Stok', prefixIcon: Icon(Icons.format_list_numbered)),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                  onSaved: (value) => _jumlahStok = int.parse(value!),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: findDropdownValue(_satuan, _satuanOptions),
                  decoration: const InputDecoration(labelText: 'Satuan', prefixIcon: Icon(Icons.ad_units)),
                  items: _satuanOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                  onChanged: (newValue) => setState(() => _satuan = newValue!),
                  onSaved: (value) => _satuan = value!,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Masuk: ${DateFormat('dd MMMM yyyy').format(_tanggalMasuk)}',
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
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
      ),
    );
  }
}