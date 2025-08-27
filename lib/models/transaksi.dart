import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kuasir/models/cart_item.dart';
import 'package:kuasir/models/barang.dart';

class TransaksiItem {
  final String barangId;
  final String namaBarang;
  final double harga;
  final int quantity;

  TransaksiItem({
    required this.barangId,
    required this.namaBarang,
    required this.harga,
    required this.quantity,
  });

  double get totalHarga => harga * quantity;

  Map<String, dynamic> toMap() {
    return {
      'barangId': barangId,
      'namaBarang': namaBarang,
      'harga': harga,
      'quantity': quantity,
    };
  }

  factory TransaksiItem.fromMap(Map<String, dynamic> map) {
    return TransaksiItem(
      barangId: map['barangId'] ?? '',
      namaBarang: map['namaBarang'] ?? '',
      harga: (map['harga'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }

  factory TransaksiItem.fromCartItem(CartItem cartItem) {
    return TransaksiItem(
      barangId: cartItem.barang.id!,
      namaBarang: cartItem.barang.namaBarang,
      harga: cartItem.barang.harga,
      quantity: cartItem.quantity,
    );
  }
}

class Transaksi {
  final String? id;
  final List<TransaksiItem> items;
  final double totalHarga;
  final DateTime tanggalTransaksi;
  final String kasirId;
  final String? notes;

  Transaksi({
    this.id,
    required this.items,
    required this.totalHarga,
    DateTime? tanggalTransaksi,
    required this.kasirId,
    this.notes,
  }) : tanggalTransaksi = tanggalTransaksi ?? DateTime.now();

  // Convert from Firestore document
  factory Transaksi.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    List<TransaksiItem> items = [];
    if (data['items'] != null) {
      items = (data['items'] as List)
          .map((item) => TransaksiItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return Transaksi(
      id: doc.id,
      items: items,
      totalHarga: (data['totalHarga'] ?? 0).toDouble(),
      tanggalTransaksi: (data['tanggalTransaksi'] as Timestamp?)?.toDate() ?? DateTime.now(),
      kasirId: data['kasirId'] ?? '',
      notes: data['notes'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'totalHarga': totalHarga,
      'tanggalTransaksi': Timestamp.fromDate(tanggalTransaksi),
      'kasirId': kasirId,
      'notes': notes,
    };
  }

  // Calculate total from items
  static double calculateTotal(List<TransaksiItem> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalHarga);
  }

  // Create from cart items
  factory Transaksi.fromCartItems({
    required List<CartItem> cartItems,
    required String kasirId,
    String? notes,
  }) {
    List<TransaksiItem> items = cartItems
        .map((cartItem) => TransaksiItem.fromCartItem(cartItem))
        .toList();
    
    double total = calculateTotal(items);

    return Transaksi(
      items: items,
      totalHarga: total,
      kasirId: kasirId,
      notes: notes,
    );
  }

  @override
  String toString() {
    return 'Transaksi(id: $id, items: ${items.length}, totalHarga: $totalHarga, tanggalTransaksi: $tanggalTransaksi)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaksi &&
        other.id == id &&
        other.totalHarga == totalHarga &&
        other.kasirId == kasirId;
  }

  @override
  int get hashCode {
    return id.hashCode ^ totalHarga.hashCode ^ kasirId.hashCode;
  }
}