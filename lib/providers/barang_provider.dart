import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kuasir/models/barang.dart';

class BarangProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Barang> _barangList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Barang> get barangList => _barangList;
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

  // Load all barang from Firestore
  Future<void> loadBarang() async {
    try {
      _setLoading(true);
      _setError(null);

      QuerySnapshot querySnapshot = await _firestore
          .collection('barang')
          .orderBy('namaBarang')
          .get();

      _barangList = querySnapshot.docs
          .map((doc) => Barang.fromFirestore(doc))
          .toList();

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Gagal memuat data barang: $e');
    }
  }

  // Listen to real-time changes
  void listenToBarang() {
    _firestore
        .collection('barang')
        .orderBy('namaBarang')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      _barangList = querySnapshot.docs
          .map((doc) => Barang.fromFirestore(doc))
          .toList();
      notifyListeners();
    }, onError: (error) {
      _setError('Gagal memuat data barang: $error');
    });
  }

  // Add new barang
  Future<bool> addBarang(Barang barang) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore.collection('barang').add(barang.toFirestore());
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Gagal menambah barang: $e');
      return false;
    }
  }

  // Update existing barang
  Future<bool> updateBarang(Barang barang) async {
    try {
      _setLoading(true);
      _setError(null);

      if (barang.id == null) {
        _setError('ID barang tidak valid');
        _setLoading(false);
        return false;
      }

      Barang updatedBarang = barang.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection('barang')
          .doc(barang.id)
          .update(updatedBarang.toFirestore());
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Gagal mengupdate barang: $e');
      return false;
    }
  }

  // Delete barang
  Future<bool> deleteBarang(String barangId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _firestore.collection('barang').doc(barangId).delete();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Gagal menghapus barang: $e');
      return false;
    }
  }

  // Find barang by barcode
  Barang? findBarangByBarcode(String barcode) {
    try {
      return _barangList.firstWhere(
        (barang) => barang.kodeBarcode == barcode,
      );
    } catch (e) {
      return null;
    }
  }

  // Find barang by ID
  Barang? findBarangById(String id) {
    try {
      return _barangList.firstWhere(
        (barang) => barang.id == id,
      );
    } catch (e) {
      return null;
    }
  }

  // Search barang by name
  List<Barang> searchBarang(String query) {
    if (query.isEmpty) return _barangList;
    
    return _barangList.where((barang) =>
        barang.namaBarang.toLowerCase().contains(query.toLowerCase()) ||
        barang.kategori.toLowerCase().contains(query.toLowerCase()) ||
        (barang.kodeBarcode?.toLowerCase().contains(query.toLowerCase()) ?? false)
    ).toList();
  }

  // Update stock after transaction
  Future<bool> updateStok(String barangId, int newStok) async {
    try {
      await _firestore.collection('barang').doc(barangId).update({
        'stok': newStok,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      _setError('Gagal mengupdate stok: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}