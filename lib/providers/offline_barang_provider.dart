import 'package:flutter/material.dart';
import 'package:kuasir/models/barang.dart';
import 'package:kuasir/services/database_helper.dart';
import 'package:uuid/uuid.dart';

class OfflineBarangProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  
  List<Barang> _barangList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Barang> get barangList => _barangList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBarang(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _barangList = await _dbHelper.getBarangList(userId);
    } catch (e) {
      _errorMessage = 'Failed to load products: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addBarang({
    required String userId,
    required String namaBarang,
    required String kategori,
    required double harga,
    required int stok,
    String? kodeBarcode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final barang = Barang(
        id: _uuid.v4(),
        namaBarang: namaBarang,
        kategori: kategori,
        kodeBarcode: kodeBarcode,
        harga: harga,
        stok: stok,
        createdAt: now,
        updatedAt: now,
      );

      bool success = await _dbHelper.insertBarang(barang, userId);
      
      if (success) {
        _barangList.add(barang);
        _barangList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to add product';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding product: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBarang({
    required String userId,
    required String barangId,
    required String namaBarang,
    required String kategori,
    required double harga,
    required int stok,
    String? kodeBarcode,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _barangList.indexWhere((b) => b.id == barangId);
      if (index == -1) {
        _errorMessage = 'Product not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final updatedBarang = Barang(
        id: barangId,
        namaBarang: namaBarang,
        kategori: kategori,
        kodeBarcode: kodeBarcode,
        harga: harga,
        stok: stok,
        createdAt: _barangList[index].createdAt,
        updatedAt: DateTime.now(),
      );

      bool success = await _dbHelper.updateBarang(updatedBarang, userId);
      
      if (success) {
        _barangList[index] = updatedBarang;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update product';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating product: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBarang(String userId, String barangId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool success = await _dbHelper.deleteBarang(barangId, userId);
      
      if (success) {
        _barangList.removeWhere((b) => b.id == barangId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to delete product';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting product: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Barang? findBarangByBarcode(String barcode) {
    try {
      return _barangList.firstWhere((barang) => barang.kodeBarcode == barcode);
    } catch (e) {
      return null;
    }
  }

  Future<Barang?> findBarangByBarcodeFromDb(String userId, String barcode) async {
    try {
      return await _dbHelper.findBarangByBarcode(barcode, userId);
    } catch (e) {
      return null;
    }
  }

  Barang? getBarangById(String id) {
    try {
      return _barangList.firstWhere((barang) => barang.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}