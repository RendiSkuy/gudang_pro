import 'dart:convert';

List<Barang> barangFromJson(String str) => List<Barang>.from(json.decode(str).map((x) => Barang.fromJson(x)));

class Barang {
    final int id;
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

    factory Barang.fromJson(Map<String, dynamic> json) => Barang(
        id: int.parse(json["id"].toString()),
        namaBarang: json["nama_barang"],
        kategori: json["kategori"],
        jumlahStok: int.parse(json["jumlah_stok"].toString()),
        satuan: json["satuan"],
        tanggalMasuk: DateTime.parse(json["tanggal_masuk"]),
    );
}