class Barang {
  final String? id;
  final String namaBarang;
  final String kategori;
  final int jumlahStok;
  final String satuan;
  final bool isActive;

  Barang({
    this.id,
    required this.namaBarang,
    required this.kategori,
    required this.jumlahStok,
    required this.satuan,
    required this.isActive,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['_id'],
      namaBarang: json['nama_barang'],
      kategori: json['kategori'],
      jumlahStok: json['jumlah_stok'],
      satuan: json['satuan'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_barang': namaBarang,
      'kategori': kategori,
      'jumlah_stok': jumlahStok,
      'satuan': satuan,
      'isActive': isActive,
    };
  }
}