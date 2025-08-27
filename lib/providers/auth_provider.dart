import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = userCredential.user;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      switch (e.code) {
        case 'user-not-found':
          _setError('Email tidak terdaftar');
          break;
        case 'wrong-password':
          _setError('Password salah');
          break;
        case 'invalid-email':
          _setError('Format email tidak valid');
          break;
        case 'user-disabled':
          _setError('Akun telah dinonaktifkan');
          break;
        case 'too-many-requests':
          _setError('Terlalu banyak percobaan, coba lagi nanti');
          break;
        default:
          _setError('Terjadi kesalahan: ${e.message}');
      }
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan: $e');
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _user = userCredential.user;
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      switch (e.code) {
        case 'weak-password':
          _setError('Password terlalu lemah');
          break;
        case 'email-already-in-use':
          _setError('Email sudah terdaftar');
          break;
        case 'invalid-email':
          _setError('Format email tidak valid');
          break;
        default:
          _setError('Terjadi kesalahan: ${e.message}');
      }
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Terjadi kesalahan: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _auth.signOut();
      _user = null;
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError('Gagal logout: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}