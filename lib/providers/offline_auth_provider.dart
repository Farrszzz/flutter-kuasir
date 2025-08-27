import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kuasir/services/database_helper.dart';

class OfflineAuthProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  OfflineAuthProvider() {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userEmail = prefs.getString('user_email');

      if (userId != null && userEmail != null) {
        _user = {
          'id': userId,
          'email': userEmail,
        };
      }
    } catch (e) {
      _errorMessage = 'Failed to check authentication state';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Email and password cannot be empty';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        _errorMessage = 'Invalid email format';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _errorMessage = 'Password must be at least 6 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Try to create user
      bool success = await _dbHelper.createUser(email, password);
      
      if (success) {
        // Auto login after successful registration
        return await signInWithEmailAndPassword(email, password);
      } else {
        _errorMessage = 'Email already exists or registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        _errorMessage = 'Email and password cannot be empty';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Try to login
      Map<String, dynamic>? userData = await _dbHelper.loginUser(email, password);
      
      if (userData != null) {
        _user = userData;
        
        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userData['id']);
        await prefs.setString('user_email', userData['email']);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      
      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Sign out failed';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}