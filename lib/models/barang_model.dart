import 'dart:convert';

List<Barang> barangFromJson(String str) =>
    List<Barang>.from(json.decode(str).map((x) => Barang.fromMap(x)));

class Barang {
  final String id;
  final String namaBarang;
  final String kategori;
  final int jumlahStok;
  final String satuan;
  final DateTime tanggalMasuk;

  Barang({
    required this.id,
    required this.namaBarang,
    required this.kategori,
    required this.jumlahStok,
    required this.satuan,
    required this.tanggalMasuk,
  });

  factory Barang.fromMap(Map<String, dynamic> json) => Barang(
        id: json["_id"] ?? '', // Juga ditambahkan pengaman jika _id null
        namaBarang: json["nama_barang"] ?? 'Tanpa Nama',
        kategori: json["kategori"] ?? 'Lainnya',
        jumlahStok: (json["jumlah_stok"] as num?)?.toInt() ?? 0,
        satuan: json["satuan"] ?? 'pcs',
        // Kode yang sudah aman untuk tanggal
        tanggalMasuk: json["tanggal_masuk"] == null
            ? DateTime.now()
            : DateTime.parse(json["tanggal_masuk"]),
      );
}