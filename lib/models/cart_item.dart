import 'package:kuasir/models/barang.dart';

class CartItem {
  final Barang barang;
  int quantity;

  CartItem({
    required this.barang,
    this.quantity = 1,
  });

  double get totalHarga => barang.harga * quantity;

  // Copy with method for updates
  CartItem copyWith({
    Barang? barang,
    int? quantity,
  }) {
    return CartItem(
      barang: barang ?? this.barang,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'CartItem(barang: ${barang.namaBarang}, quantity: $quantity, totalHarga: $totalHarga)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.barang.id == barang.id &&
        other.quantity == quantity;
  }

  @override
  int get hashCode => barang.id.hashCode ^ quantity.hashCode;
}