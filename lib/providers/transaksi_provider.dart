import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kuasir/models/transaksi.dart';
import 'package:kuasir/models/cart_item.dart';

class TransaksiProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Transaksi> _transaksiList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Transaksi> get transaksiList => _transaksiList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Load all transactions
  Future<void> loadTransaksi() async {
    try {
      _setLoading(true);
      _setError(null);

      QuerySnapshot querySnapshot = await _firestore
          .collection('transaksi')
          .orderBy('tanggalTransaksi', descending: true)
          .get();

      _transaksiList = querySnapshot.docs
          .map((doc) => Transaksi.fromFirestore(doc))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Gagal memuat data transaksi: $e');
    }
  }

  // Listen to real-time changes
  void listenToTransaksi() {
    _firestore
        .collection('transaksi')
        .orderBy('tanggalTransaksi', descending: true)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      _transaksiList = querySnapshot.docs
          .map((doc) => Transaksi.fromFirestore(doc))
          .toList();
      notifyListeners();
    }, onError: (error) {
      _setError('Gagal memuat data transaksi: $error');
    });
  }

  // Create new transaction
  Future<bool> createTransaksi({
    required List<CartItem> cartItems,
    required String kasirId,
    String? notes,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Create transaction from cart items
      Transaksi transaksi = Transaksi.fromCartItems(
        cartItems: cartItems,
        kasirId: kasirId,
        notes: notes,
      );

      // Save transaction to Firestore
      await _firestore.collection('transaksi').add(transaksi.toFirestore());
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Gagal menyimpan transaksi: $e');
      return false;
    }
  }

  // Get transactions by kasir ID
  List<Transaksi> getTransaksiByKasir(String kasirId) {
    return _transaksiList.where((transaksi) => transaksi.kasirId == kasirId).toList();
  }

  // Get transactions by date range
  List<Transaksi> getTransaksiByDateRange(DateTime startDate, DateTime endDate) {
    return _transaksiList.where((transaksi) {
      DateTime transaksiDate = DateTime(
        transaksi.tanggalTransaksi.year,
        transaksi.tanggalTransaksi.month,
        transaksi.tanggalTransaksi.day,
      );
      DateTime start = DateTime(startDate.year, startDate.month, startDate.day);
      DateTime end = DateTime(endDate.year, endDate.month, endDate.day);
      
      return transaksiDate.isAtSameMomentAs(start) ||
             transaksiDate.isAtSameMomentAs(end) ||
             (transaksiDate.isAfter(start) && transaksiDate.isBefore(end));
    }).toList();
  }

  // Get today's transactions
  List<Transaksi> getTodayTransaksi() {
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);
    
    return _transaksiList.where((transaksi) {
      return transaksi.tanggalTransaksi.isAfter(startOfDay) &&
             transaksi.tanggalTransaksi.isBefore(endOfDay);
    }).toList();
  }

  // Calculate daily sales
  double getTodaySales() {
    List<Transaksi> todayTransaksi = getTodayTransaksi();
    return todayTransaksi.fold(0.0, (sum, transaksi) => sum + transaksi.totalHarga);
  }

  // Calculate monthly sales
  double getMonthlySales() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    List<Transaksi> monthlyTransaksi = getTransaksiByDateRange(startOfMonth, endOfMonth);
    return monthlyTransaksi.fold(0.0, (sum, transaksi) => sum + transaksi.totalHarga);
  }

  // Get sales summary
  Map<String, dynamic> getSalesSummary() {
    List<Transaksi> todayTransaksi = getTodayTransaksi();
    double todaySales = getTodaySales();
    double monthlySales = getMonthlySales();
    
    return {
      'todayTransactions': todayTransaksi.length,
      'todaySales': todaySales,
      'monthlySales': monthlySales,
      'totalTransactions': _transaksiList.length,
    };
  }

  // Delete transaction (admin only)
  Future<bool> deleteTransaksi(String transaksiId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore.collection('transaksi').doc(transaksiId).delete();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Gagal menghapus transaksi: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}