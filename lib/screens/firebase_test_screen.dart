import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _authStatus = 'Testing...';
  String _firestoreStatus = 'Testing...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _testFirebaseServices();
  }

  Future<void> _testFirebaseServices() async {
    // Test Firebase Authentication
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      await auth.createUserWithEmailAndPassword(
        email: 'test@test.com',
        password: 'test123',
      );
      setState(() {
        _authStatus = '✅ Authentication is enabled and working';
      });
      // Delete test user
      await auth.currentUser?.delete();
    } catch (e) {
      if (e.toString().contains('CONFIGURATION_NOT_FOUND')) {
        setState(() {
          _authStatus = '❌ Authentication not enabled in Firebase Console';
        });
      } else if (e.toString().contains('email-already-in-use')) {
        setState(() {
          _authStatus = '✅ Authentication is enabled (test email already exists)';
        });
      } else {
        setState(() {
          _authStatus = '⚠️ Authentication error: ${e.toString()}';
        });
      }
    }

    // Test Firestore
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('test').set({'test': true});
      await firestore.collection('test').doc('test').delete();
      setState(() {
        _firestoreStatus = '✅ Firestore is enabled and working';
      });
    } catch (e) {
      if (e.toString().contains('PERMISSION_DENIED') || 
          e.toString().contains('CONFIGURATION_NOT_FOUND')) {
        setState(() {
          _firestoreStatus = '❌ Firestore not enabled in Firebase Console';
        });
      } else {
        setState(() {
          _firestoreStatus = '⚠️ Firestore error: ${e.toString()}';
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Service Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Firebase Services Status',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Authentication Status
                    Row(
                      children: [
                        const Icon(Icons.security, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Firebase Authentication',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : Text(_authStatus),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Firestore Status
                    Row(
                      children: [
                        const Icon(Icons.storage, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cloud Firestore',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              _isLoading
                                  ? const CircularProgressIndicator()
                                  : Text(_firestoreStatus),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (!_isLoading) ...[
              if (_authStatus.contains('❌') || _firestoreStatus.contains('❌'))
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Text(
                              'Action Required',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please enable Firebase services in Firebase Console:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        const Text('1. Go to https://console.firebase.google.com/project/kuasirku'),
                        const Text('2. Enable Authentication > Email/Password'),
                        const Text('3. Enable Firestore Database > Test mode'),
                      ],
                    ),
                  ),
                ),
              
              if (_authStatus.contains('✅') && _firestoreStatus.contains('✅'))
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'All Firebase services are ready!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () {
                  setState(() {
                    _isLoading = true;
                    _authStatus = 'Testing...';
                    _firestoreStatus = 'Testing...';
                  });
                  _testFirebaseServices();
                },
                child: const Text('Retest Firebase Services'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}