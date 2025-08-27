import 'package:flutter/foundation.dart';
import 'package:kuasir/models/barang.dart';
import 'package:kuasir/models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];
  
  List<CartItem> get cartItems => _cartItems;
  
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalHarga => _cartItems.fold(0.0, (sum, item) => sum + item.totalHarga);
  
  bool get isEmpty => _cartItems.isEmpty;
  
  bool get isNotEmpty => _cartItems.isNotEmpty;

  // Add item to cart
  void addItem(Barang barang, {int quantity = 1}) {
    // Check if item already exists in cart
    int existingIndex = _cartItems.indexWhere(
      (item) => item.barang.id == barang.id,
    );

    if (existingIndex >= 0) {
      // Item exists, update quantity
      _cartItems[existingIndex].quantity += quantity;
    } else {
      // Item doesn't exist, add new item
      _cartItems.add(CartItem(barang: barang, quantity: quantity));
    }
    
    notifyListeners();
  }

  // Remove item from cart
  void removeItem(String barangId) {
    _cartItems.removeWhere((item) => item.barang.id == barangId);
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(String barangId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(barangId);
      return;
    }

    int index = _cartItems.indexWhere((item) => item.barang.id == barangId);
    if (index >= 0) {
      _cartItems[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  // Increase item quantity
  void increaseQuantity(String barangId) {
    int index = _cartItems.indexWhere((item) => item.barang.id == barangId);
    if (index >= 0) {
      _cartItems[index].quantity++;
      notifyListeners();
    }
  }

  // Decrease item quantity
  void decreaseQuantity(String barangId) {
    int index = _cartItems.indexWhere((item) => item.barang.id == barangId);
    if (index >= 0) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Clear all items from cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Check if item exists in cart
  bool containsItem(String barangId) {
    return _cartItems.any((item) => item.barang.id == barangId);
  }

  // Get item quantity by barang ID
  int getItemQuantity(String barangId) {
    try {
      CartItem item = _cartItems.firstWhere(
        (item) => item.barang.id == barangId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  // Get cart item by barang ID
  CartItem? getCartItem(String barangId) {
    try {
      return _cartItems.firstWhere(
        (item) => item.barang.id == barangId,
      );
    } catch (e) {
      return null;
    }
  }

  // Validate cart items against available stock
  List<String> validateStock() {
    List<String> errors = [];
    
    for (CartItem item in _cartItems) {
      if (item.quantity > item.barang.stok) {
        errors.add(
          '${item.barang.namaBarang}: Stok tidak mencukupi (Tersedia: ${item.barang.stok}, Diminta: ${item.quantity})'
        );
      }
    }
    
    return errors;
  }

  // Get cart summary
  Map<String, dynamic> getCartSummary() {
    return {
      'totalItems': itemCount,
      'totalHarga': totalHarga,
      'itemsCount': _cartItems.length,
    };
  }
}