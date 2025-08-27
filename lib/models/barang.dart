import 'package:cloud_firestore/cloud_firestore.dart';

class Barang {
  final String? id;
  final String namaBarang;
  final String kategori;
  final String? kodeBarcode;
  final double harga;
  final int stok;
  final DateTime createdAt;
  final DateTime updatedAt;

  Barang({
    this.id,
    required this.namaBarang,
    required this.kategori,
    this.kodeBarcode,
    required this.harga,
    required this.stok,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert from Firestore document
  factory Barang.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Barang(
      id: doc.id,
      namaBarang: data['namaBarang'] ?? '',
      kategori: data['kategori'] ?? '',
      kodeBarcode: data['kodeBarcode'],
      harga: (data['harga'] ?? 0).toDouble(),
      stok: data['stok'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'namaBarang': namaBarang,
      'kategori': kategori,
      'kodeBarcode': kodeBarcode,
      'harga': harga,
      'stok': stok,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy with method for updates
  Barang copyWith({
    String? id,
    String? namaBarang,
    String? kategori,
    String? kodeBarcode,
    double? harga,
    int? stok,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Barang(
      id: id ?? this.id,
      namaBarang: namaBarang ?? this.namaBarang,
      kategori: kategori ?? this.kategori,
      kodeBarcode: kodeBarcode ?? this.kodeBarcode,
      harga: harga ?? this.harga,
      stok: stok ?? this.stok,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Barang(id: $id, namaBarang: $namaBarang, kategori: $kategori, kodeBarcode: $kodeBarcode, harga: $harga, stok: $stok)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Barang &&
        other.id == id &&
        other.namaBarang == namaBarang &&
        other.kategori == kategori &&
        other.kodeBarcode == kodeBarcode &&
        other.harga == harga &&
        other.stok == stok;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        namaBarang.hashCode ^
        kategori.hashCode ^
        kodeBarcode.hashCode ^
        harga.hashCode ^
        stok.hashCode;
  }
}