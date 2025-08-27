import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kuasir/providers/barang_provider.dart';
import 'package:kuasir/providers/cart_provider.dart';
import 'package:kuasir/providers/auth_provider.dart';
import 'package:kuasir/providers/transaksi_provider.dart';
import 'package:kuasir/models/barang.dart';
import 'package:kuasir/models/cart_item.dart';
import 'package:kuasir/widgets/barcode_scanner_widget.dart';
import 'package:kuasir/screens/checkout_screen.dart';
import 'package:intl/intl.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBarang();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBarang() async {
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    await barangProvider.loadBarang();
  }

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
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    final barang = barangProvider.findBarangByBarcode(barcode);
    
    if (barang != null) {
      if (barang.stok > 0) {
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
        ),
      );
    }
  }

  void _addItemToCart(Barang barang) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    if (barang.stok > 0) {
      // Check if adding this item would exceed stock
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
  }

  void _showItemQuantityDialog(Barang barang) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currentQuantity = cartProvider.getItemQuantity(barang.id!);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int quantity = currentQuantity > 0 ? currentQuantity : 1;
        
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(barang.namaBarang),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Stok tersedia: ${barang.stok} unit'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: quantity > 1 
                            ? () => setState(() => quantity--) 
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 8
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quantity.toString(),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      IconButton(
                        onPressed: quantity < barang.stok 
                            ? () => setState(() => quantity++) 
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Batal'),
                ),
                if (currentQuantity > 0)
                  TextButton(
                    onPressed: () {
                      cartProvider.removeItem(barang.id!);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                  ),
                FilledButton(
                  onPressed: () {
                    cartProvider.updateQuantity(barang.id!, quantity);
                    Navigator.of(context).pop();
                  },
                  child: Text(currentQuantity > 0 ? 'Update' : 'Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _scanBarcode,
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return IconButton(
                onPressed: cartProvider.isNotEmpty 
                    ? () => _showCartDialog() 
                    : null,
                icon: Badge(
                  isLabelVisible: cartProvider.isNotEmpty,
                  label: Text(cartProvider.itemCount.toString()),
                  child: const Icon(Icons.shopping_cart),
                ),
                tooltip: 'Keranjang',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Products Grid
          Expanded(
            child: Consumer<BarangProvider>(
              builder: (context, barangProvider, child) {
                if (barangProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (barangProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          barangProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadBarang,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredBarang = barangProvider.searchBarang(_searchQuery);

                if (filteredBarang.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty ? 'Belum ada produk' : 'Produk tidak ditemukan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty 
                              ? 'Tambahkan produk di menu Barang'
                              : 'Coba kata kunci lain atau scan barcode',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadBarang,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredBarang.length,
                    itemBuilder: (context, index) {
                      final barang = filteredBarang[index];
                      
                      return Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          final inCart = cartProvider.containsItem(barang.id!);
                          final quantity = cartProvider.getItemQuantity(barang.id!);
                          
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () => _showItemQuantityDialog(barang),
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product Image Placeholder
                                    Container(
                                      width: double.infinity,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surfaceVariant,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.inventory,
                                        size: 32,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Product Name
                                    Text(
                                      barang.namaBarang,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),

                                    // Category
                                    Text(
                                      barang.kategori,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Price
                                    Text(
                                      formatCurrency.format(barang.harga),
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Stock
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.inventory_2,
                                          size: 16,
                                          color: barang.stok > 10
                                              ? Colors.green
                                              : barang.stok > 0
                                                  ? Colors.orange
                                                  : Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${barang.stok} unit',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: barang.stok > 10
                                                ? Colors.green
                                                : barang.stok > 0
                                                    ? Colors.orange
                                                    : Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),

                                    // Add to Cart Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: inCart
                                          ? OutlinedButton.icon(
                                              onPressed: () => _showItemQuantityDialog(barang),
                                              icon: const Icon(Icons.edit),
                                              label: Text('$quantity di keranjang'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Theme.of(context).colorScheme.primary,
                                              ),
                                            )
                                          : FilledButton.icon(
                                              onPressed: barang.stok > 0 
                                                  ? () => _addItemToCart(barang)
                                                  : null,
                                              icon: const Icon(Icons.add_shopping_cart),
                                              label: const Text('Tambah'),
                                              style: FilledButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Cart Summary (if not empty)
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.isEmpty) return const SizedBox.shrink();
              
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${cartProvider.itemCount} item dalam keranjang',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            formatCurrency.format(cartProvider.totalHarga),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CheckoutScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.payment),
                      label: const Text('Checkout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showCartDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CartBottomSheet(),
    );
  }
}

class CartBottomSheet extends StatelessWidget {
  const CartBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (context, scrollController) {
        return Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Keranjang Belanja',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (cartProvider.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            cartProvider.clearCart();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Kosongkan'),
                        ),
                    ],
                  ),
                ),

                // Cart Items
                Expanded(
                  child: cartProvider.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text('Keranjang kosong'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: cartProvider.cartItems.length,
                          itemBuilder: (context, index) {
                            final cartItem = cartProvider.cartItems[index];
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Product Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cartItem.barang.namaBarang,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            formatCurrency.format(cartItem.barang.harga),
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Quantity Controls
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            cartProvider.decreaseQuantity(cartItem.barang.id!);
                                          },
                                          icon: const Icon(Icons.remove),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            cartItem.quantity.toString(),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: cartItem.quantity < cartItem.barang.stok
                                              ? () {
                                                  cartProvider.increaseQuantity(cartItem.barang.id!);
                                                }
                                              : null,
                                          icon: const Icon(Icons.add),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Total and Checkout
                if (cartProvider.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total (${cartProvider.itemCount} item)',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              formatCurrency.format(cartProvider.totalHarga),
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CheckoutScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.payment),
                            label: const Text('Lanjut ke Pembayaran'),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}