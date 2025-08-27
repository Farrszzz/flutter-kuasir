import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kuasir/providers/barang_provider.dart';
import 'package:kuasir/models/barang.dart';
import 'package:kuasir/widgets/barcode_generator_widget.dart';
import 'package:kuasir/widgets/barcode_scanner_widget.dart';

class AddEditBarangScreen extends StatefulWidget {
  final Barang? barang;
  final String? initialBarcode;

  const AddEditBarangScreen({
    super.key,
    this.barang,
    this.initialBarcode,
  });

  @override
  State<AddEditBarangScreen> createState() => _AddEditBarangScreenState();
}

class _AddEditBarangScreenState extends State<AddEditBarangScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaBarangController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _kodeBarcodeController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();

  bool get isEditing => widget.barang != null;

  // Predefined categories
  final List<String> _predefinedKategori = [
    'Makanan',
    'Minuman',
    'Elektronik',
    'Pakaian',
    'Kesehatan',
    'Kecantikan',
    'Olahraga',
    'Buku',
    'Alat Tulis',
    'Rumah Tangga',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (isEditing) {
      _namaBarangController.text = widget.barang!.namaBarang;
      _kategoriController.text = widget.barang!.kategori;
      _kodeBarcodeController.text = widget.barang!.kodeBarcode ?? '';
      _hargaController.text = widget.barang!.harga.toString();
      _stokController.text = widget.barang!.stok.toString();
    } else if (widget.initialBarcode != null) {
      _kodeBarcodeController.text = widget.initialBarcode!;
    }
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _kategoriController.dispose();
    _kodeBarcodeController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _saveBarang() async {
    if (_formKey.currentState!.validate()) {
      final barangProvider = Provider.of<BarangProvider>(context, listen: false);
      
      final barang = Barang(
        id: isEditing ? widget.barang!.id : null,
        namaBarang: _namaBarangController.text.trim(),
        kategori: _kategoriController.text.trim(),
        kodeBarcode: _kodeBarcodeController.text.trim().isEmpty 
            ? null 
            : _kodeBarcodeController.text.trim(),
        harga: double.parse(_hargaController.text),
        stok: int.parse(_stokController.text),
        createdAt: isEditing ? widget.barang!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (isEditing) {
        success = await barangProvider.updateBarang(barang);
      } else {
        success = await barangProvider.addBarang(barang);
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? 'Barang berhasil diupdate' : 'Barang berhasil ditambahkan',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _scanBarcode() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeScannerWidget(
          title: 'Scan Barcode',
          onBarcodeScanned: (barcode) {
            setState(() {
              _kodeBarcodeController.text = barcode;
            });
          },
        ),
      ),
    );
  }

  void _generateBarcode() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BarcodeGeneratorWidget(
          initialData: _kodeBarcodeController.text.isNotEmpty 
              ? _kodeBarcodeController.text 
              : null,
          onBarcodeGenerated: (barcode) {
            setState(() {
              _kodeBarcodeController.text = barcode;
            });
          },
        ),
      ),
    ).then((result) {
      if (result != null && result is String) {
        setState(() {
          _kodeBarcodeController.text = result;
        });
      }
    });
  }

  void _showKategoriPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pilih Kategori'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _predefinedKategori.length,
              itemBuilder: (context, index) {
                final kategori = _predefinedKategori[index];
                return ListTile(
                  title: Text(kategori),
                  onTap: () {
                    setState(() {
                      _kategoriController.text = kategori;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Barang' : 'Tambah Barang'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<BarangProvider>(
            builder: (context, barangProvider, child) {
              return barangProvider.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      onPressed: _saveBarang,
                      icon: const Icon(Icons.save),
                      tooltip: 'Simpan',
                    );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Basic Information Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Dasar',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nama Barang
                      TextFormField(
                        controller: _namaBarangController,
                        decoration: InputDecoration(
                          labelText: 'Nama Barang *',
                          hintText: 'Masukkan nama barang',
                          prefixIcon: const Icon(Icons.inventory),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama barang tidak boleh kosong';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Kategori
                      TextFormField(
                        controller: _kategoriController,
                        decoration: InputDecoration(
                          labelText: 'Kategori *',
                          hintText: 'Masukkan kategori barang',
                          prefixIcon: const Icon(Icons.category),
                          suffixIcon: IconButton(
                            onPressed: _showKategoriPicker,
                            icon: const Icon(Icons.arrow_drop_down),
                            tooltip: 'Pilih Kategori',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Kategori tidak boleh kosong';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Barcode Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Barcode',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _kodeBarcodeController,
                        decoration: InputDecoration(
                          labelText: 'Kode Barcode',
                          hintText: 'Scan atau generate barcode',
                          prefixIcon: const Icon(Icons.qr_code),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        readOnly: false,
                      ),
                      const SizedBox(height: 12),

                      // Barcode Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _scanBarcode,
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('Scan'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _generateBarcode,
                              icon: const Icon(Icons.qr_code_2),
                              label: const Text('Generate'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Price and Stock Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Harga & Stok',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          // Harga
                          Expanded(
                            child: TextFormField(
                              controller: _hargaController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: 'Harga *',
                                hintText: '0',
                                prefixIcon: const Icon(Icons.attach_money),
                                prefixText: 'Rp ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Harga tidak boleh kosong';
                                }
                                final harga = double.tryParse(value);
                                if (harga == null || harga < 0) {
                                  return 'Harga tidak valid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Stok
                          Expanded(
                            child: TextFormField(
                              controller: _stokController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: 'Stok *',
                                hintText: '0',
                                prefixIcon: const Icon(Icons.inventory_2),
                                suffixText: 'unit',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Stok tidak boleh kosong';
                                }
                                final stok = int.tryParse(value);
                                if (stok == null || stok < 0) {
                                  return 'Stok tidak valid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error Message
              Consumer<BarangProvider>(
                builder: (context, barangProvider, child) {
                  if (barangProvider.errorMessage != null) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              barangProvider.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Save Button
              Consumer<BarangProvider>(
                builder: (context, barangProvider, child) {
                  return FilledButton(
                    onPressed: barangProvider.isLoading ? null : _saveBarang,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: barangProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            isEditing ? 'Update Barang' : 'Simpan Barang',
                            style: const TextStyle(fontSize: 16),
                          ),
                  );
                },
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
                        'Field dengan tanda (*) wajib diisi. Barcode bersifat opsional.',
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
        ),
      ),
    );
  }
}