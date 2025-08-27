import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kuasir/models/barang.dart';

class NoAuthBarangProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Barang> _barangList = [];
  bool _isLoading = false;
  String? _errorMessage;
  final bool _useFirebase;

  // Constructor to specify if Firebase should be used
  NoAuthBarangProvider({bool useFirebase = true}) : _useFirebase = useFirebase;

  List<Barang> get barangList => _barangList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get useFirebase => _useFirebase; // Add getter for Firebase mode

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Load all barang from Firestore or local storage
  Future<void> loadBarang() async {
    try {
      _setLoading(true);
      _setError(null);

      if (_useFirebase) {
        try {
          print('Loading barang from Firebase...');
          // Use public collection without authentication
          QuerySnapshot querySnapshot = await _firestore
              .collection('barang')
              .orderBy('namaBarang')
              .get();

          _barangList = querySnapshot.docs
              .map((doc) => Barang.fromFirestore(doc))
              .toList();
          
          print('Successfully loaded ${_barangList.length} items from Firebase');
          
          // If no data in Firebase, add demo data
          if (_barangList.isEmpty) {
            print('No data in Firebase, loading demo data...');
            await _addDemoDataToFirebase();
            // Reload after adding demo data
            querySnapshot = await _firestore
                .collection('barang')
                .orderBy('namaBarang')
                .get();
            _barangList = querySnapshot.docs
                .map((doc) => Barang.fromFirestore(doc))
                .toList();
          }
        } catch (e) {
          // If Firebase fails, fallback to demo data
          print('Firebase failed, using demo data: $e');
          _barangList = _getDemoData();
          _setError('Menggunakan data demo (Firebase error: ${e.toString().substring(0, 50)}...)');
        }
      } else {
        // Use local storage or demo data
        print('Loading demo data (local mode)...');
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
        _barangList = _getDemoData();
      }

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Gagal memuat data barang: $e');
      // Always provide demo data as fallback
      _barangList = _getDemoData();
    }
  }

  // Get demo data for testing
  List<Barang> _getDemoData() {
    return [
      Barang(
        id: 'demo1',
        namaBarang: 'Indomie Goreng',
        kategori: 'Makanan',
        kodeBarcode: '8992388113032',
        harga: 3000,
        stok: 50,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Barang(
        id: 'demo2',
        namaBarang: 'Coca Cola 330ml',
        kategori: 'Minuman',
        kodeBarcode: '8888001234567',
        harga: 5000,
        stok: 24,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Barang(
        id: 'demo3',
        namaBarang: 'Beras Premium 5kg',
        kategori: 'Sembako',
        kodeBarcode: '8999999123456',
        harga: 65000,
        stok: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Add demo data to Firebase when collection is empty
  Future<void> _addDemoDataToFirebase() async {
    if (!_useFirebase) return;
    
    try {
      final demoData = _getDemoData();
      final batch = _firestore.batch();
      
      for (final barang in demoData) {
        final docRef = _firestore.collection('barang').doc();
        batch.set(docRef, barang.toFirestore());
      }
      
      await batch.commit();
      print('Demo data added to Firebase successfully');
    } catch (e) {
      print('Failed to add demo data to Firebase: $e');
    }
  }

  // Listen to real-time changes (only if using Firebase)
  void listenToBarang() {
    if (!_useFirebase) return;

    try {
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
    } catch (e) {
      _setError('Gagal menghubungkan ke Firebase: $e');
    }
  }

  // Add new barang
  Future<bool> addBarang(Barang barang) async {
    try {
      _setLoading(true);
      _setError(null);

      if (_useFirebase) {
        try {
          print('Adding barang to Firebase: ${barang.namaBarang}');
          await _firestore.collection('barang').add(barang.toFirestore());
          print('Successfully added to Firebase');
          
          // Reload data to get the updated list with proper IDs
          await loadBarang();
        } catch (e) {
          // If Firebase fails, add to local list instead
          print('Firebase add failed, using local: $e');
          Barang newBarang = barang.copyWith(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          );
          _barangList.add(newBarang);
          _barangList.sort((a, b) => a.namaBarang.compareTo(b.namaBarang));
          _setError('Data disimpan lokal (Firebase error)');
        }
      } else {
        // Add to local list with generated ID
        await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
        Barang newBarang = barang.copyWith(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        );
        _barangList.add(newBarang);
        _barangList.sort((a, b) => a.namaBarang.compareTo(b.namaBarang));
      }
      
      _setLoading(false);
      notifyListeners();
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

      if (_useFirebase) {
        try {
          print('Updating barang in Firebase: ${updatedBarang.namaBarang}');
          await _firestore
              .collection('barang')
              .doc(barang.id)
              .update(updatedBarang.toFirestore());
          print('Successfully updated in Firebase');
          
          // Reload data to get the updated list
          await loadBarang();
        } catch (e) {
          // If Firebase fails, update local list instead
          print('Firebase update failed, using local: $e');
          int index = _barangList.indexWhere((b) => b.id == barang.id);
          if (index != -1) {
            _barangList[index] = updatedBarang;
          }
          _setError('Data diupdate lokal (Firebase error)');
        }
      } else {
        // Update in local list
        await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
        int index = _barangList.indexWhere((b) => b.id == barang.id);
        if (index != -1) {
          _barangList[index] = updatedBarang;
        }
      }
      
      _setLoading(false);
      notifyListeners();
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

      bool deletedSuccessfully = false;

      if (_useFirebase) {
        try {
          print('Deleting barang from Firebase: $barangId');
          await _firestore.collection('barang').doc(barangId).delete();
          print('Successfully deleted from Firebase');
          deletedSuccessfully = true;
          
          // Reload data to get the updated list
          await loadBarang();
        } catch (e) {
          // If Firebase fails, remove from local list instead
          print('Firebase delete failed, using local: $e');
          int originalLength = _barangList.length;
          _barangList.removeWhere((b) => b.id == barangId);
          deletedSuccessfully = _barangList.length < originalLength;
          _setError('Data dihapus lokal (Firebase error)');
        }
      } else {
        // Remove from local list
        await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
        int originalLength = _barangList.length;
        _barangList.removeWhere((b) => b.id == barangId);
        deletedSuccessfully = _barangList.length < originalLength;
        
        // Debug log
        print('Local delete: Original length: $originalLength, New length: ${_barangList.length}, Deleted ID: $barangId');
        if (!deletedSuccessfully) {
          print('Available IDs: ${_barangList.map((b) => b.id).toList()}');
        }
      }
      
      _setLoading(false);
      notifyListeners();
      
      if (!deletedSuccessfully) {
        _setError('Barang tidak ditemukan untuk dihapus');
      }
      
      return deletedSuccessfully;
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
      if (_useFirebase) {
        await _firestore.collection('barang').doc(barangId).update({
          'stok': newStok,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        // Update local stock
        int index = _barangList.indexWhere((b) => b.id == barangId);
        if (index != -1) {
          _barangList[index] = _barangList[index].copyWith(
            stok: newStok,
            updatedAt: DateTime.now(),
          );
        }
      }
      notifyListeners();
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