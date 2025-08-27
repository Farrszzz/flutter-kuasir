import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kuasir/providers/barang_provider.dart';
import 'package:kuasir/models/barang.dart';
import 'package:kuasir/screens/add_edit_barang_screen.dart';
import 'package:kuasir/widgets/barcode_scanner_widget.dart';
import 'package:intl/intl.dart';

class BarangScreen extends StatefulWidget {
  const BarangScreen({super.key});

  @override
  State<BarangScreen> createState() => _BarangScreenState();
}

class _BarangScreenState extends State<BarangScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Barang> _filteredBarang = [];
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

  void _filterBarang(List<Barang> allBarang) {
    if (_searchQuery.isEmpty) {
      _filteredBarang = allBarang;
    } else {
      _filteredBarang = allBarang.where((barang) {
        return barang.namaBarang.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               barang.kategori.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (barang.kodeBarcode?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }
  }

  void _showDeleteDialog(Barang barang) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Barang'),
          content: Text('Apakah Anda yakin ingin menghapus "${barang.namaBarang}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final barangProvider = Provider.of<BarangProvider>(context, listen: false);
                bool success = await barangProvider.deleteBarang(barang.id!);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Barang berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _scanBarcode() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWidget(
          title: 'Scan Barcode Barang',
          onBarcodeScanned: (barcode) {
            final barangProvider = Provider.of<BarangProvider>(context, listen: false);
            final foundBarang = barangProvider.findBarangByBarcode(barcode);
            
            if (foundBarang != null) {
              // Show barang details
              _showBarangDetails(foundBarang);
            } else {
              // Show option to create new barang with this barcode
              _showCreateBarangOption(barcode);
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
              _buildDetailRow('Kategori', barang.kategori),
              _buildDetailRow('Harga', NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(barang.harga)),
              _buildDetailRow('Stok', '${barang.stok} unit'),
              if (barang.kodeBarcode != null)
                _buildDetailRow('Barcode', barang.kodeBarcode!),
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEditBarangScreen(barang: barang),
                  ),
                );
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateBarangOption(String barcode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Barang Tidak Ditemukan'),
          content: Text('Barang dengan barcode "$barcode" tidak ditemukan. Apakah Anda ingin membuat barang baru?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddEditBarangScreen(initialBarcode: barcode),
                  ),
                );
              },
              child: const Text('Buat Barang'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
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
        title: const Text('Kelola Barang'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _scanBarcode,
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
          ),
          IconButton(
            onPressed: _loadBarang,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
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
                hintText: 'Cari barang...',
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

          // Barang List
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

                _filterBarang(barangProvider.barangList);

                if (_filteredBarang.isEmpty) {
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
                          _searchQuery.isEmpty ? 'Belum ada barang' : 'Barang tidak ditemukan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty 
                              ? 'Tambahkan barang pertama Anda'
                              : 'Coba kata kunci lain',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadBarang,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredBarang.length,
                    itemBuilder: (context, index) {
                      final barang = _filteredBarang[index];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () => _showBarangDetails(barang),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            barang.namaBarang,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            barang.kategori,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => AddEditBarangScreen(barang: barang),
                                            ),
                                          );
                                        } else if (value == 'delete') {
                                          _showDeleteDialog(barang);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
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
                                              Text('Hapus', style: TextStyle(color: Colors.red)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Harga',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                            ),
                                          ),
                                          Text(
                                            formatCurrency.format(barang.harga),
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Stok',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: barang.stok > 10
                                                ? Colors.green.withOpacity(0.1)
                                                : barang.stok > 0
                                                    ? Colors.orange.withOpacity(0.1)
                                                    : Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${barang.stok} unit',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: barang.stok > 10
                                                  ? Colors.green
                                                  : barang.stok > 0
                                                      ? Colors.orange
                                                      : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (barang.kodeBarcode != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.qr_code,
                                          size: 16,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          barang.kodeBarcode!,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontFamily: 'monospace',
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditBarangScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Barang'),
      ),
    );
  }
}