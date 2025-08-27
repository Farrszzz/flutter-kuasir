import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:kuasir/models/cart_item.dart';
import 'package:intl/intl.dart';

class BluetoothPrinterWidget extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalHarga;
  final String? notes;
  final VoidCallback? onPrintComplete;

  const BluetoothPrinterWidget({
    super.key,
    required this.cartItems,
    required this.totalHarga,
    this.notes,
    this.onPrintComplete,
  });

  @override
  State<BluetoothPrinterWidget> createState() => _BluetoothPrinterWidgetState();
}

class _BluetoothPrinterWidgetState extends State<BluetoothPrinterWidget> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;
  bool _isScanning = false;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  Future<void> _initBluetooth() async {
    try {
      // Try to get bonded devices directly
      _getDevices();
    } catch (e) {
      _showError('Gagal menginisialisasi Bluetooth: $e');
    }
  }

  Future<void> _getDevices() async {
    setState(() {
      _isScanning = true;
    });

    try {
      List<BluetoothDevice> devices = await bluetooth.getBondedDevices();
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      _showError('Gagal mendapatkan perangkat Bluetooth: $e');
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    try {
      await bluetooth.connect(device);
      setState(() {
        _selectedDevice = device;
        _isConnected = true;
      });
      _showSuccess('Terhubung ke ${device.name}');
    } catch (e) {
      _showError('Gagal terhubung ke ${device.name}: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      await bluetooth.disconnect();
      setState(() {
        _selectedDevice = null;
        _isConnected = false;
      });
      _showSuccess('Terputus dari printer');
    } catch (e) {
      _showError('Gagal memutus koneksi: $e');
    }
  }

  Future<void> _printReceipt() async {
    if (!_isConnected || _selectedDevice == null) {
      _showError('Tidak terhubung ke printer');
      return;
    }

    setState(() {
      _isPrinting = true;
    });

    try {
      final formatCurrency = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'id_ID');

      // Print header
      bluetooth.printNewLine();
      bluetooth.printCustom('KUASIR STORE', 3, 1); // Title, size 3, center
      bluetooth.printCustom('Jl. Contoh No. 123', 1, 1);
      bluetooth.printCustom('Telp: 0812-3456-7890', 1, 1);
      bluetooth.printNewLine();
      bluetooth.printCustom('================================', 1, 1);
      bluetooth.printNewLine();

      // Transaction info
      bluetooth.printCustom('Tanggal: ${dateFormat.format(DateTime.now())}', 1, 0);
      bluetooth.printCustom('Kasir: Kuasir User', 1, 0);
      bluetooth.printNewLine();
      bluetooth.printCustom('--------------------------------', 1, 1);

      // Items
      for (var cartItem in widget.cartItems) {
        bluetooth.printCustom(cartItem.barang.namaBarang, 1, 0);
        bluetooth.printCustom(
          '${cartItem.quantity} x ${formatCurrency.format(cartItem.barang.harga)}',
          1,
          0,
        );
        bluetooth.printCustom(
          '${' ' * 20}${formatCurrency.format(cartItem.totalHarga)}',
          1,
          2, // Right align
        );
        bluetooth.printNewLine();
      }

      bluetooth.printCustom('--------------------------------', 1, 1);

      // Total
      bluetooth.printCustom('TOTAL', 2, 0);
      bluetooth.printCustom(formatCurrency.format(widget.totalHarga), 2, 2);
      bluetooth.printNewLine();

      // Notes
      if (widget.notes != null && widget.notes!.isNotEmpty) {
        bluetooth.printCustom('Catatan:', 1, 0);
        bluetooth.printCustom(widget.notes!, 1, 0);
        bluetooth.printNewLine();
      }

      bluetooth.printCustom('================================', 1, 1);
      bluetooth.printCustom('Terima Kasih', 2, 1);
      bluetooth.printCustom('Selamat Berbelanja Kembali', 1, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      bluetooth.printNewLine();

      _showSuccess('Struk berhasil dicetak');
      
      if (widget.onPrintComplete != null) {
        widget.onPrintComplete!();
      }
    } catch (e) {
      _showError('Gagal mencetak struk: $e');
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _testPrint() {
    if (!_isConnected) {
      _showError('Tidak terhubung ke printer');
      return;
    }

    try {
      bluetooth.printNewLine();
      bluetooth.printCustom('TEST PRINT', 2, 1);
      bluetooth.printCustom('Printer berhasil terhubung', 1, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      _showSuccess('Test print berhasil');
    } catch (e) {
      _showError('Test print gagal: $e');
    }
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
        title: const Text('Cetak Struk'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isConnected)
            IconButton(
              onPressed: _testPrint,
              icon: const Icon(Icons.print),
              tooltip: 'Test Print',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status Card
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
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                          color: _isConnected ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status Koneksi',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isConnected 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _isConnected ? 'Terhubung' : 'Tidak Terhubung',
                            style: TextStyle(
                              color: _isConnected ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_selectedDevice != null) ...[
                      const SizedBox(height: 8),
                      Text('Printer: ${_selectedDevice!.name}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Available Devices Card
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
                    Row(
                      children: [
                        Text(
                          'Perangkat Bluetooth',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: _isScanning ? null : _getDevices,
                          icon: _isScanning 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_devices.isEmpty)
                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.bluetooth_disabled, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tidak ada perangkat ditemukan'),
                            Text('Pastikan printer sudah dipasangkan'),
                          ],
                        ),
                      )
                    else
                      ..._devices.map((device) {
                        final isSelected = _selectedDevice?.address == device.address;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : null,
                          child: ListTile(
                            leading: Icon(
                              Icons.print,
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                            title: Text(device.name ?? 'Unknown Device'),
                            subtitle: Text(device.address ?? ''),
                            trailing: isSelected && _isConnected
                                ? FilledButton(
                                    onPressed: _disconnect,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Putus'),
                                  )
                                : FilledButton(
                                    onPressed: () => _connect(device),
                                    child: const Text('Hubungkan'),
                                  ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Receipt Preview Card
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
                      'Preview Struk',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Receipt Preview
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          // Header
                          const Text(
                            'KUASIR STORE',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Jl. Contoh No. 123'),
                          const Text('Telp: 0812-3456-7890'),
                          const SizedBox(height: 8),
                          const Divider(),

                          // Transaction Info
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tanggal:'),
                              Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),
                            ],
                          ),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Kasir:'),
                              Text('Kuasir User'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),

                          // Items
                          ...widget.cartItems.map((cartItem) {
                            return Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cartItem.barang.namaBarang,
                                            style: const TextStyle(fontWeight: FontWeight.w500),
                                          ),
                                          Text(
                                            '${cartItem.quantity} x ${formatCurrency.format(cartItem.barang.harga)}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      formatCurrency.format(cartItem.totalHarga),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            );
                          }).toList(),

                          const Divider(),

                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'TOTAL',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatCurrency.format(widget.totalHarga),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          if (widget.notes != null && widget.notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            const Divider(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Catatan: '),
                                Expanded(child: Text(widget.notes!)),
                              ],
                            ),
                          ],

                          const SizedBox(height: 8),
                          const Divider(),
                          const Text(
                            'Terima Kasih',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text('Selamat Berbelanja Kembali'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Print Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isConnected && !_isPrinting ? _printReceipt : null,
                icon: _isPrinting 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.print),
                label: Text(
                  _isPrinting 
                      ? 'Mencetak...' 
                      : _isConnected 
                          ? 'Cetak Struk'
                          : 'Hubungkan Printer Dulu',
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

            // Skip Print Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onPrintComplete,
                icon: const Icon(Icons.skip_next),
                label: const Text('Lewati Cetak Struk'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}