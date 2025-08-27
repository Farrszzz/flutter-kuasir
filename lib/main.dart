// Kuasir - Modern POS System
//
// FIREBASE SETUP REQUIRED:
// 1. Create Firebase project at https://console.firebase.google.com
// 2. Run: dart pub global activate flutterfire_cli
// 3. Run: flutterfire configure
// 4. Enable Authentication and Firestore in Firebase Console
// 5. Set USE_AUTHENTICATION = true below to enable Firebase features
//
// For detailed setup instructions, see FIREBASE_SETUP_TEMPLATE.md

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:kuasir/providers/auth_provider.dart';
import 'package:kuasir/providers/barang_provider.dart';
import 'package:kuasir/providers/cart_provider.dart';
import 'package:kuasir/providers/transaksi_provider.dart';
import 'package:kuasir/providers/no_auth_barang_provider.dart';
import 'package:kuasir/models/barang.dart';
import 'package:kuasir/models/transaksi.dart';
import 'package:kuasir/models/cart_item.dart';
import 'package:kuasir/widgets/barcode_scanner_widget.dart';
import 'package:kuasir/widgets/bluetooth_printer_widget.dart';
import 'package:kuasir/widgets/bluetooth_printer_widget.dart';
import 'package:kuasir/screens/login_screen.dart';
import 'package:kuasir/screens/dashboard_screen.dart';
import 'package:kuasir/screens/firebase_test_screen.dart';
// import 'firebase_options.dart'; // Commented out - users should configure their own Firebase

// ** CONFIG: Set this to false to disable authentication **
const bool USE_AUTHENTICATION = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If not using authentication, run the no-auth version directly
  if (!USE_AUTHENTICATION) {
    try {
      await Firebase.initializeApp(
        // Note: Users should create their own firebase_options.dart
        // by running 'flutterfire configure' after setting up Firebase project
        // options: DefaultFirebaseOptions.currentPlatform,
      );
      // Always try Firebase first, but with better error handling
      print('Firebase initialized successfully');
      runApp(const KuasirNoAuthApp(useFirebase: true));
    } catch (e) {
      // If Firebase fails completely, run without Firebase
      print('Firebase initialization failed, using local mode: $e');
      runApp(const KuasirNoAuthApp(useFirebase: false));
    }
    return;
  }

  // Original authentication flow
  try {
    await Firebase.initializeApp(
      // Note: Users should create their own firebase_options.dart
      // by running 'flutterfire configure' after setting up Firebase project
      // options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                const Text('Firebase connection failed'),
                const SizedBox(height: 8),
                Text('Error: $e', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('Retry Online'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please enable Firebase services or use offline APK',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    runApp(
                      MaterialApp(
                        home: const FirebaseTestScreen(),
                        theme: ThemeData(
                          colorScheme: ColorScheme.fromSeed(
                            seedColor: const Color(0xFF00BCD4),
                          ),
                          useMaterial3: true,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test Firebase Services'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// No-Auth App (Original from main_no_auth.dart)
class KuasirNoAuthApp extends StatelessWidget {
  final bool useFirebase;

  const KuasirNoAuthApp({super.key, this.useFirebase = true});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => NoAuthBarangProvider(useFirebase: useFirebase),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => TransaksiProvider()),
      ],
      child: MaterialApp(
        title: 'Kuasir - Sistem Kasir Toko',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: LoadingScreen(useFirebase: useFirebase),
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BCD4), // Teal color
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  final bool useFirebase;

  const LoadingScreen({super.key, required this.useFirebase});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show loading for a moment
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Load initial data
      if (widget.useFirebase) {
        try {
          await Provider.of<NoAuthBarangProvider>(
            context,
            listen: false,
          ).loadBarang();
          await Provider.of<TransaksiProvider>(
            context,
            listen: false,
          ).loadTransaksi();
        } catch (e) {
          // If loading fails, continue anyway
          print('Error loading data: $e');
        }
      } else {
        // Load demo data for offline mode
        await Provider.of<NoAuthBarangProvider>(
          context,
          listen: false,
        ).loadBarang();
      }

      // Navigate to dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              NoAuthDashboard(useFirebase: widget.useFirebase),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Logo.png',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.point_of_sale,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // App Name
              Text(
                'Kuasir',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sistem Kasir Toko',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 40),

              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                widget.useFirebase
                    ? 'Memuat data dari cloud...'
                    : 'Memuat aplikasi...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Complete NoAuth Dashboard with full functionality
class NoAuthDashboard extends StatefulWidget {
  final bool useFirebase;

  const NoAuthDashboard({super.key, required this.useFirebase});

  @override
  State<NoAuthDashboard> createState() => _NoAuthDashboardState();
}

class _NoAuthDashboardState extends State<NoAuthDashboard> {
  int _selectedIndex = 0;

  // Search and filter variables for transaction screen
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Helper method to get unique categories
  List<String> _getCategories(List<Barang> products) {
    final categories = products.map((p) => p.kategori).toSet().toList();
    categories.sort();
    return ['Semua', ...categories];
  }

  // Helper method to filter products based on search and category
  List<Barang> _filterProducts(List<Barang> products) {
    var filtered = products;

    // Filter by category
    if (_selectedCategory != 'Semua') {
      filtered = filtered
          .where((p) => p.kategori == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.namaBarang.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                (p.kodeBarcode != null &&
                    p.kodeBarcode!.contains(_searchQuery)),
          )
          .toList();
    }

    return filtered;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildDashboardHome(),
      _buildBarangScreen(),
      _buildTransaksiScreen(),
      _buildHistoryScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_outlined),
            selectedIcon: Icon(Icons.inventory),
            label: 'Barang',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHome() {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Kuasir Dashboard'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: widget.useFirebase ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.useFirebase ? 'CLOUD' : 'LOCAL',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Consumer<NoAuthBarangProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang di Kuasir',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.useFirebase
                              ? 'Sistem kasir dengan sinkronisasi cloud'
                              : 'Sistem kasir dengan penyimpanan lokal',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white.withOpacity(0.9)),
                        ),
                        if (provider.errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              provider.errorMessage!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Aksi Cepat',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildQuickActionCard(
                  title: 'Kelola Barang',
                  subtitle: 'Tambah, edit barang',
                  icon: Icons.inventory,
                  color: Colors.orange,
                  onTap: () => _onItemTapped(1),
                ),
                _buildQuickActionCard(
                  title: 'Transaksi Baru',
                  subtitle: 'Mulai penjualan',
                  icon: Icons.shopping_cart,
                  color: Colors.green,
                  onTap: () => _onItemTapped(2),
                ),
                _buildQuickActionCard(
                  title: 'Riwayat Transaksi',
                  subtitle: 'Lihat penjualan',
                  icon: Icons.history,
                  color: Colors.purple,
                  onTap: () => _onItemTapped(3),
                ),
                _buildQuickActionCard(
                  title: 'Scan Barcode',
                  subtitle: 'Scan produk',
                  icon: Icons.qr_code_scanner,
                  color: Colors.blue,
                  onTap: () => _onItemTapped(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarangScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Barang'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _scanBarcodeForBarang(),
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
          ),
        ],
      ),
      body: Consumer<NoAuthBarangProvider>(
        builder: (context, barangProvider, child) {
          if (barangProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (barangProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(barangProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => barangProvider.loadBarang(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (barangProvider.barangList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Belum ada barang'),
                  const SizedBox(height: 8),
                  const Text('Tap + untuk menambah barang pertama'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => barangProvider.loadBarang(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: barangProvider.barangList.length,
              itemBuilder: (context, index) {
                final barang = barangProvider.barangList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.inventory, color: Colors.orange),
                    ),
                    title: Text(
                      barang.namaBarang,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${barang.kategori} • Rp ${barang.harga.toStringAsFixed(0)}',
                        ),
                        Text(
                          'Stok: ${barang.stok}',
                          style: TextStyle(
                            color: barang.stok > 10
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Hapus'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditBarangDialog(barang);
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(barang);
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBarangDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTransaksiScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _scanBarcode(),
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Badge(
                isLabelVisible: cartProvider.isNotEmpty,
                label: Text('${cartProvider.itemCount}'),
                child: IconButton(
                  onPressed: () => _showCart(),
                  icon: const Icon(Icons.shopping_cart),
                  tooltip: 'Keranjang',
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari produk berdasarkan nama atau barcode...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Category Filter
                Consumer<NoAuthBarangProvider>(
                  builder: (context, barangProvider, child) {
                    final categories = _getCategories(
                      barangProvider.barangList,
                    );

                    return Container(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = _selectedCategory == category;

                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              backgroundColor: Colors.grey.shade100,
                              selectedColor: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.2),
                              checkmarkColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade700,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Cart Summary at top
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${cartProvider.itemCount} item dalam keranjang',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  'Total: ${_formatCurrency(cartProvider.totalHarga)}',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _showCart(),
                            child: const Text('Lihat'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 8),

          // Product List
          Expanded(
            child: Consumer<NoAuthBarangProvider>(
              builder: (context, barangProvider, child) {
                if (barangProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (barangProvider.barangList.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Belum ada produk'),
                        Text('Tambahkan produk di tab Barang terlebih dahulu'),
                      ],
                    ),
                  );
                }

                // Filter products based on search and category
                final filteredProducts = _filterProducts(
                  barangProvider.barangList,
                );

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada produk ditemukan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Coba kata kunci lain atau hapus filter'
                              : 'Coba ganti kategori atau hapus filter',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                              _selectedCategory = 'Semua';
                            });
                          },
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Hapus Semua Filter'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final barang = filteredProducts[index];
                    return Consumer<CartProvider>(
                      builder: (context, cartProvider, child) {
                        final inCart = cartProvider.containsItem(barang.id!);
                        final cartQuantity = cartProvider.getItemQuantity(
                          barang.id!,
                        );

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.inventory_2,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              barang.namaBarang,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    barang.kategori,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Stok: ${barang.stok}',
                                  style: TextStyle(
                                    color: barang.stok <= 5
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (barang.kodeBarcode != null)
                                  Text(
                                    'Barcode: ${barang.kodeBarcode}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatCurrency(barang.harga),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                if (inCart)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      'x$cartQuantity',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onTap: () => _addToCart(barang),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () => _showCheckout(),
              label: const Text('Checkout'),
              icon: const Icon(Icons.payment),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHistoryScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _showDateFilter(),
            icon: const Icon(Icons.date_range),
            tooltip: 'Filter Tanggal',
          ),
          IconButton(
            onPressed: () {
              Provider.of<TransaksiProvider>(
                context,
                listen: false,
              ).loadTransaksi();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<TransaksiProvider>(
        builder: (context, transaksiProvider, child) {
          if (transaksiProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (transaksiProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(transaksiProvider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => transaksiProvider.loadTransaksi(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final transaksiList = transaksiProvider.transaksiList;

          if (transaksiList.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada transaksi'),
                  Text('Transaksi akan muncul di sini setelah checkout'),
                ],
              ),
            );
          }

          // Calculate summary
          final totalTransaksi = transaksiList.length;
          final totalPenjualan = transaksiList.fold(
            0.0,
            (sum, transaksi) => sum + transaksi.totalHarga,
          );
          final todayTransaksi = transaksiProvider.getTodayTransaksi();
          final todaySales = todayTransaksi.fold(
            0.0,
            (sum, transaksi) => sum + transaksi.totalHarga,
          );

          return RefreshIndicator(
            onRefresh: () => transaksiProvider.loadTransaksi(),
            child: Column(
              children: [
                // Summary Cards
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  'Hari Ini',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${todayTransaksi.length}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  _formatCurrency(todaySales),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  'Total',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$totalTransaksi',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  _formatCurrency(totalPenjualan),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Transaction List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transaksiList.length,
                    itemBuilder: (context, index) {
                      final transaksi = transaksiList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.receipt,
                              color: Colors.green,
                            ),
                          ),
                          title: Text(
                            'Transaksi #${transaksi.id?.substring(0, 8) ?? 'Unknown'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_formatDateTime(transaksi.tanggalTransaksi)),
                              Text(
                                '${transaksi.items.length} item${transaksi.items.length > 1 ? 's' : ''}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              if (transaksi.notes != null)
                                Text(
                                  'Catatan: ${transaksi.notes}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Text(
                            _formatCurrency(transaksi.totalHarga),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          onTap: () => _showTransaksiDetail(transaksi),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Currency formatter
  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // DateTime formatter
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Add item to cart
  void _addToCart(Barang barang) {
    if (barang.stok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${barang.namaBarang} sedang habis'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currentQuantity = cartProvider.getItemQuantity(barang.id!);

    if (currentQuantity >= barang.stok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok ${barang.namaBarang} tidak mencukupi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    cartProvider.addItem(barang);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${barang.namaBarang} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Show cart dialog
  void _showCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keranjang Belanja'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.isEmpty) {
                return const Center(child: Text('Keranjang kosong'));
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartProvider.cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartProvider.cartItems[index];
                        return Card(
                          child: ListTile(
                            title: Text(cartItem.barang.namaBarang),
                            subtitle: Text(
                              _formatCurrency(cartItem.barang.harga),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    cartProvider.decreaseQuantity(
                                      cartItem.barang.id!,
                                    );
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                Text('${cartItem.quantity}'),
                                IconButton(
                                  onPressed: () {
                                    if (cartItem.quantity <
                                        cartItem.barang.stok) {
                                      cartProvider.increaseQuantity(
                                        cartItem.barang.id!,
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatCurrency(cartProvider.totalHarga),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return ElevatedButton(
                onPressed: cartProvider.isEmpty
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        _showCheckout();
                      },
                child: const Text('Checkout'),
              );
            },
          ),
        ],
      ),
    );
  }

  // Show checkout dialog
  void _showCheckout() {
    final notesController = TextEditingController();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ringkasan Pesanan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...cartProvider.cartItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.barang.namaBarang} x${item.quantity}',
                          ),
                        ),
                        Text(_formatCurrency(item.totalHarga)),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatCurrency(cartProvider.totalHarga),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    hintText: 'Tambahkan catatan untuk transaksi ini',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => _processCheckout(notesController.text),
            child: const Text('Bayar'),
          ),
        ],
      ),
    );
  }

  // Process checkout
  Future<void> _processCheckout(String notes) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final transaksiProvider = Provider.of<TransaksiProvider>(
      context,
      listen: false,
    );
    final barangProvider = Provider.of<NoAuthBarangProvider>(
      context,
      listen: false,
    );

    // Validate stock
    final stockErrors = cartProvider.validateStock();
    if (stockErrors.isNotEmpty) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Stok Tidak Mencukupi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stockErrors.map((error) => Text('• $error')).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      // Save transaction using createTransaksi method
      final success = await transaksiProvider.createTransaksi(
        cartItems: cartProvider.cartItems,
        kasirId: 'kuasir_user',
        notes: notes.isEmpty ? null : notes,
      );

      if (success) {
        // Update stock for each item
        for (final cartItem in cartProvider.cartItems) {
          final updatedBarang = cartItem.barang.copyWith(
            stok: cartItem.barang.stok - cartItem.quantity,
            updatedAt: DateTime.now(),
          );
          await barangProvider.updateBarang(updatedBarang);
        }

        // Save cart items for potential receipt printing
        final cartItems = List.from(cartProvider.cartItems);
        final totalHarga = cartProvider.totalHarga;

        // Clear cart
        cartProvider.clearCart();

        Navigator.of(context).pop();

        // Show success message with print option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaksi berhasil disimpan!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Cetak Struk',
              textColor: Colors.white,
              onPressed: () {
                _showPrintDialog(cartItems, totalHarga, notes);
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );

        // Switch to history tab
        _onItemTapped(3);
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan transaksi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Show transaction detail
  void _showTransaksiDetail(Transaksi transaksi) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Detail Transaksi #${transaksi.id?.substring(0, 8) ?? 'Unknown'}',
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tanggal: ${_formatDateTime(transaksi.tanggalTransaksi)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Kasir: ${transaksi.kasirId}'),
                if (transaksi.notes != null)
                  Text('Catatan: ${transaksi.notes}'),
                const SizedBox(height: 16),
                Text(
                  'Item Pembelian:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...transaksi.items.map(
                  (item) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.namaBarang,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${_formatCurrency(item.harga)} x ${item.quantity}',
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatCurrency(item.totalHarga),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formatCurrency(transaksi.totalHarga),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showPrintDialogFromTransaction(transaksi);
            },
            child: const Text('Cetak Ulang'),
          ),
        ],
      ),
    );
  }

  // Show date filter dialog
  void _showDateFilter() {
    // Simple implementation - can be enhanced later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filter tanggal akan tersedia di versi berikutnya'),
      ),
    );
  }

  // Show print dialog for receipt printing
  void _showPrintDialog(
    List<dynamic> cartItems,
    double totalHarga,
    String notes,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cetak Struk'),
        content: const Text(
          'Hubungkan ke printer Bluetooth untuk mencetak struk transaksi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showBluetoothPrinter(cartItems, totalHarga, notes);
            },
            child: const Text('Cetak'),
          ),
        ],
      ),
    );
  }

  // Show Bluetooth printer widget
  void _showBluetoothPrinter(
    List<dynamic> cartItems,
    double totalHarga,
    String notes,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Cetak Struk'),
            backgroundColor: Colors.transparent,
          ),
          body: BluetoothPrinterWidget(
            cartItems: cartItems.cast(),
            totalHarga: totalHarga,
            notes: notes.isEmpty ? null : notes,
            onPrintComplete: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Struk berhasil dicetak!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Show print dialog from transaction history
  void _showPrintDialogFromTransaction(Transaksi transaksi) {
    // Convert transaction items to cart items for printing
    final cartItems = transaksi.items.map((item) {
      // Create a temporary Barang object for the cart item
      final barang = Barang(
        id: item.barangId,
        namaBarang: item.namaBarang,
        kategori: '', // Not stored in transaction item
        harga: item.harga,
        stok: 0, // Not relevant for printing
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Return CartItem for printing
      return CartItem(barang: barang, quantity: item.quantity);
    }).toList();

    _showPrintDialog(cartItems, transaksi.totalHarga, transaksi.notes ?? '');
  }

  // Barcode scanning functionality
  void _scanBarcode() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWidget(
          title: 'Scan Barcode Produk',
          onBarcodeScanned: (barcode) {
            _addItemByBarcode(barcode);
          },
        ),
      ),
    );
  }

  void _addItemByBarcode(String barcode) {
    final barangProvider = Provider.of<NoAuthBarangProvider>(
      context,
      listen: false,
    );
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Find product by barcode
    final barang = barangProvider.barangList.firstWhere(
      (item) => item.kodeBarcode == barcode,
      orElse: () => Barang(
        id: '',
        namaBarang: '',
        kategori: '',
        harga: 0,
        stok: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (barang.id!.isNotEmpty) {
      if (barang.stok > 0) {
        final currentQuantity = cartProvider.getItemQuantity(barang.id!);

        if (currentQuantity >= barang.stok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Stok ${barang.namaBarang} tidak mencukupi'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        cartProvider.addItem(barang);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${barang.namaBarang} ditambahkan ke keranjang'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${barang.namaBarang} sedang tidak tersedia'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk dengan barcode "$barcode" tidak ditemukan'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Tambah Produk',
            textColor: Colors.white,
            onPressed: () {
              _showAddBarangWithBarcode(barcode);
            },
          ),
        ),
      );
    }
  }

  // Scan barcode for product management
  void _scanBarcodeForBarang() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWidget(
          title: 'Scan Barcode Barang',
          onBarcodeScanned: (barcode) {
            final barangProvider = Provider.of<NoAuthBarangProvider>(
              context,
              listen: false,
            );
            final foundBarang = barangProvider.barangList.firstWhere(
              (item) => item.kodeBarcode == barcode,
              orElse: () => Barang(
                id: '',
                namaBarang: '',
                kategori: '',
                harga: 0,
                stok: 0,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );

            if (foundBarang.id!.isNotEmpty) {
              // Show product details
              _showBarangDetails(foundBarang);
            } else {
              // Show option to create new product with this barcode
              _showAddBarangWithBarcode(barcode);
            }
          },
        ),
      ),
    );
  }

  void _showBarangDetails(Barang barang) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(barang.namaBarang),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kategori: ${barang.kategori}'),
              Text('Harga: ${_formatCurrency(barang.harga)}'),
              Text('Stok: ${barang.stok}'),
              if (barang.kodeBarcode != null)
                Text('Barcode: ${barang.kodeBarcode}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showEditBarangDialog(barang);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _showAddBarangWithBarcode(String barcode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Produk Tidak Ditemukan'),
          content: Text(
            'Produk dengan barcode "$barcode" tidak ditemukan.\n\nApakah Anda ingin menambahkan produk baru dengan barcode ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showAddBarangDialogWithBarcode(barcode);
              },
              child: const Text('Tambah Produk'),
            ),
          ],
        );
      },
    );
  }

  void _showAddBarangDialogWithBarcode(String barcode) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final barcodeController = TextEditingController(text: barcode);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Barang Baru'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Barang',
                    hintText: 'Masukkan nama barang',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    hintText: 'Masukkan kategori barang',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    hintText: 'Masukkan harga barang',
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    hintText: 'Masukkan jumlah stok',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Barcode',
                    hintText: 'Barcode dari scan',
                    enabled: false,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  categoryController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  stockController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon isi semua field yang diperlukan'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final barang = Barang(
                  id: '',
                  namaBarang: nameController.text,
                  kategori: categoryController.text,
                  harga: double.parse(priceController.text),
                  stok: int.parse(stockController.text),
                  kodeBarcode: barcode,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await Provider.of<NoAuthBarangProvider>(
                  context,
                  listen: false,
                ).addBarang(barang);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Barang berhasil ditambahkan dengan barcode'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAddBarangDialog() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final barcodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Barang Baru'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Barang',
                    hintText: 'Masukkan nama barang',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    hintText: 'Masukkan kategori barang',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    hintText: 'Masukkan harga barang',
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    hintText: 'Masukkan jumlah stok',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: barcodeController,
                        decoration: const InputDecoration(
                          labelText: 'Barcode (Opsional)',
                          hintText: 'Masukkan atau scan barcode',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BarcodeScannerWidget(
                              title: 'Scan Barcode Produk',
                              onBarcodeScanned: (barcode) {
                                barcodeController.text = barcode;
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      tooltip: 'Scan Barcode',
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  categoryController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  stockController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon isi semua field yang diperlukan'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final barang = Barang(
                  id: '',
                  namaBarang: nameController.text,
                  kategori: categoryController.text,
                  harga: double.parse(priceController.text),
                  stok: int.parse(stockController.text),
                  kodeBarcode: barcodeController.text.isEmpty
                      ? null
                      : barcodeController.text,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                await Provider.of<NoAuthBarangProvider>(
                  context,
                  listen: false,
                ).addBarang(barang);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Barang berhasil ditambahkan'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditBarangDialog(Barang barang) {
    final nameController = TextEditingController(text: barang.namaBarang);
    final categoryController = TextEditingController(text: barang.kategori);
    final priceController = TextEditingController(
      text: barang.harga.toString(),
    );
    final stockController = TextEditingController(text: barang.stok.toString());
    final barcodeController = TextEditingController(
      text: barang.kodeBarcode ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Barang'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Barang',
                    hintText: 'Masukkan nama barang',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    hintText: 'Masukkan kategori barang',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                    hintText: 'Masukkan harga barang',
                    prefixText: 'Rp ',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    hintText: 'Masukkan jumlah stok',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Barcode (Opsional)',
                    hintText: 'Masukkan barcode',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isEmpty ||
                  categoryController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  stockController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mohon isi semua field yang diperlukan'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final updatedBarang = Barang(
                  id: barang.id,
                  namaBarang: nameController.text,
                  kategori: categoryController.text,
                  harga: double.parse(priceController.text),
                  stok: int.parse(stockController.text),
                  kodeBarcode: barcodeController.text.isEmpty
                      ? null
                      : barcodeController.text,
                  createdAt: barang.createdAt,
                  updatedAt: DateTime.now(),
                );

                await Provider.of<NoAuthBarangProvider>(
                  context,
                  listen: false,
                ).updateBarang(updatedBarang);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Barang berhasil diperbarui'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Barang barang) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${barang.namaBarang}"?\n\nTindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                if (barang.id == null) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error: ID barang tidak valid'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Show loading state
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialog(
                    content: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Menghapus barang...'),
                      ],
                    ),
                  ),
                );

                bool success = await Provider.of<NoAuthBarangProvider>(
                  context,
                  listen: false,
                ).deleteBarang(barang.id!);

                // Close loading dialog
                Navigator.pop(context);
                // Close confirmation dialog
                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Barang berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gagal menghapus barang'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                // Close any open dialogs
                Navigator.pop(context); // Close loading dialog if open
                Navigator.pop(context); // Close confirmation dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BarangProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => TransaksiProvider()),
      ],
      child: MaterialApp(
        title: 'Kuasir - Sistem Kasir Modern',
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        home: const AuthWrapper(),
      ),
    );
  }
}

// Authentication wrapper to check if user is logged in
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
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
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
