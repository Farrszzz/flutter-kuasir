import 'package:flutter/material.dart';
import 'package:kuasir/models/transaksi.dart';
import 'package:kuasir/models/cart_item.dart';
import 'package:kuasir/services/database_helper.dart';
import 'package:uuid/uuid.dart';

class OfflineTransaksiProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  
  List<Transaksi> _transaksiList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Transaksi> get transaksiList => _transaksiList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTransaksi(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transaksiList = await _dbHelper.getTransaksiList(userId);
    } catch (e) {
      _errorMessage = 'Failed to load transactions: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addTransaksi({
    required String userId,
    required List<CartItem> items,
    required double total,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final transaksi = Transaksi(
        id: _uuid.v4(),
        items: items,
        total: total,
        createdAt: DateTime.now(),
      );

      bool success = await _dbHelper.insertTransaksi(transaksi, userId);
      
      if (success) {
        _transaksiList.insert(0, transaksi); // Add to beginning for latest first
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to save transaction';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error saving transaction: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Map<String, dynamic> getSalesSummary() {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      // Today's transactions
      final todayTransactions = _transaksiList.where((t) => 
        t.createdAt.isAfter(today) || t.createdAt.isAtSameMomentAs(today)
      ).toList();

      // Monthly transactions
      final monthlyTransactions = _transaksiList.where((t) => 
        t.createdAt.isAfter(monthStart) || t.createdAt.isAtSameMomentAs(monthStart)
      ).toList();

      // Calculate totals
      double todaySales = todayTransactions.fold(0.0, (sum, t) => sum + t.total);
      double monthlySales = monthlyTransactions.fold(0.0, (sum, t) => sum + t.total);

      return {
        'todaySales': todaySales,
        'todayTransactions': todayTransactions.length,
        'monthlySales': monthlySales,
        'totalTransactions': monthlyTransactions.length,
      };
    } catch (e) {
      return {
        'todaySales': 0.0,
        'todayTransactions': 0,
        'monthlySales': 0.0,
        'totalTransactions': 0,
      };
    }
  }

  List<Transaksi> getTransaksiByDateRange(DateTime start, DateTime end) {
    return _transaksiList.where((t) => 
      t.createdAt.isAfter(start) && t.createdAt.isBefore(end)
    ).toList();
  }

  List<Transaksi> getTodayTransaksi() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return getTransaksiByDateRange(today, tomorrow);
  }

  List<Transaksi> getThisMonthTransaksi() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    
    return getTransaksiByDateRange(monthStart, nextMonth);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}