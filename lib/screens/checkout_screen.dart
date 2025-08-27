import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kuasir/providers/cart_provider.dart';
import 'package:kuasir/providers/auth_provider.dart';
import 'package:kuasir/providers/transaksi_provider.dart';
import 'package:kuasir/providers/barang_provider.dart';
import 'package:kuasir/widgets/bluetooth_printer_widget.dart';
import 'package:intl/intl.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processTransaction() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transaksiProvider = Provider.of<TransaksiProvider>(context, listen: false);
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);

    if (cartProvider.isEmpty) {
      _showErrorMessage('Keranjang kosong');
      return;
    }

    if (authProvider.user == null) {
      _showErrorMessage('User tidak terautentikasi');
      return;
    }

    // Validate stock before processing
    final stockErrors = cartProvider.validateStock();
    if (stockErrors.isNotEmpty) {
      _showStockErrorDialog(stockErrors);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Create transaction
      bool success = await transaksiProvider.createTransaksi(
        cartItems: cartProvider.cartItems,
        kasirId: authProvider.user!.uid,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      if (success) {
        // Update stock for each item
        for (var cartItem in cartProvider.cartItems) {
          final newStok = cartItem.barang.stok - cartItem.quantity;
          await barangProvider.updateStok(cartItem.barang.id!, newStok);
        }

        // Show success and offer to print receipt
        _showSuccessDialog();
      } else {
        _showErrorMessage(transaksiProvider.errorMessage ?? 'Gagal memproses transaksi');
      }
    } catch (e) {
      _showErrorMessage('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showStockErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stok Tidak Mencukupi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Item berikut memiliki stok tidak mencukupi:'),
              const SizedBox(height: 8),
              ...errors.map((error) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $error'),
              )),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 28),
              SizedBox(width: 8),
              Text('Transaksi Berhasil'),
            ],
          ),
          content: const Text('Transaksi telah berhasil diproses. Apakah Anda ingin mencetak struk?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _finishTransaction();
              },
              child: const Text('Nanti'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _printReceipt();
              },
              child: const Text('Cetak Struk'),
            ),
          ],
        );
      },
    );
  }

  void _printReceipt() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BluetoothPrinterWidget(
          cartItems: cartProvider.cartItems,
          totalHarga: cartProvider.totalHarga,
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
          onPrintComplete: _finishTransaction,
        ),
      ),
    );
  }

  void _finishTransaction() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.clearCart();
    
    // Navigate back to transaction screen
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaksi selesai'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
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
        title: const Text('Checkout'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) {
            return const Center(
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
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Summary Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Pesanan',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Items List
                        ...cartProvider.cartItems.map((cartItem) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.barang.namaBarang,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${cartItem.quantity} x ${formatCurrency.format(cartItem.barang.harga)}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  formatCurrency.format(cartItem.totalHarga),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        const Divider(),

                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total (${cartProvider.itemCount} item)',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Notes Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan (Opsional)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Tambahkan catatan untuk transaksi ini...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Payment Info Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Pembayaran',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tanggal: ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(DateTime.now())}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Kasir: ${authProvider.user?.email ?? 'Unknown'}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Process Transaction Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isProcessing ? null : _processTransaction,
                    icon: _isProcessing 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.payment),
                    label: Text(
                      _isProcessing ? 'Memproses...' : 'Proses Transaksi',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pastikan semua item sudah sesuai sebelum memproses transaksi.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}