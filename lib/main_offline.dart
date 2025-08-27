import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kuasir/providers/offline_auth_provider.dart';
import 'package:kuasir/providers/offline_barang_provider.dart';
import 'package:kuasir/providers/cart_provider.dart';
import 'package:kuasir/providers/offline_transaksi_provider.dart';
import 'package:kuasir/screens/offline_login_screen.dart';
import 'package:kuasir/screens/offline_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const OfflineKuasirApp());
}

class OfflineKuasirApp extends StatelessWidget {
  const OfflineKuasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OfflineAuthProvider()),
        ChangeNotifierProvider(create: (_) => OfflineBarangProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OfflineTransaksiProvider()),
      ],
      child: MaterialApp(
        title: 'Kuasir - Offline POS System',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00BCD4), // Teal color
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        home: const OfflineAuthWrapper(),
      ),
    );
  }
}

// Authentication wrapper to check if user is logged in
class OfflineAuthWrapper extends StatelessWidget {
  const OfflineAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OfflineAuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat aplikasi...'),
                ],
              ),
            ),
          );
        }

        // Navigate based on authentication status
        if (authProvider.isAuthenticated) {
          return const OfflineDashboardScreen();
        } else {
          return const OfflineLoginScreen();
        }
      },
    );
  }
}