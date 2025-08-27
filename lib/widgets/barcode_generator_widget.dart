import 'package:flutter/material.dart';
import 'package:barcode/barcode.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class BarcodeGeneratorWidget extends StatefulWidget {
  final String? initialData;
  final Function(String)? onBarcodeGenerated;

  const BarcodeGeneratorWidget({
    super.key,
    this.initialData,
    this.onBarcodeGenerated,
  });

  @override
  State<BarcodeGeneratorWidget> createState() => _BarcodeGeneratorWidgetState();
}

class _BarcodeGeneratorWidgetState extends State<BarcodeGeneratorWidget> {
  final TextEditingController _dataController = TextEditingController();
  String? _generatedBarcode;
  BarcodeType _selectedType = BarcodeType.Code128;
  Uint8List? _barcodeImage;
  
  final List<BarcodeType> _supportedTypes = [
    BarcodeType.Code128,
    BarcodeType.Code39,
    BarcodeType.Code93,
    BarcodeType.CodeEAN13,
    BarcodeType.CodeEAN8,
    BarcodeType.CodeUPCA,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _dataController.text = widget.initialData!;
      _generateBarcode();
    }
  }

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  void _generateBarcode() {
    final data = _dataController.text.trim();
    if (data.isEmpty) {
      setState(() {
        _barcodeImage = null;
        _generatedBarcode = null;
      });
      return;
    }

    try {
      final bc = Barcode.fromType(_selectedType);
      
      // Validate the data for the selected barcode type
      if (!bc.isValid(data)) {
        _showError('Data tidak valid untuk jenis barcode ${_selectedType.name}');
        return;
      }

      // Generate SVG
      final svg = bc.toSvg(data, width: 300, height: 80);
      
      // Convert SVG to displayable format (simplified)
      setState(() {
        _generatedBarcode = data;
        // Note: For actual image generation, you'd need additional packages
        // This is a simplified version showing the concept
      });

      if (widget.onBarcodeGenerated != null) {
        widget.onBarcodeGenerated!(data);
      }

      _showSuccess('Barcode berhasil dibuat!');
    } catch (e) {
      _showError('Gagal membuat barcode: $e');
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

  void _copyBarcode() {
    if (_generatedBarcode != null) {
      Clipboard.setData(ClipboardData(text: _generatedBarcode!));
      _showSuccess('Kode barcode disalin ke clipboard');
    }
  }

  String _generateRandomBarcode() {
    switch (_selectedType) {
      case BarcodeType.CodeEAN13:
        // Generate 13 digit EAN code
        return '${DateTime.now().millisecondsSinceEpoch}'.substring(0, 13).padLeft(13, '0');
      case BarcodeType.CodeEAN8:
        // Generate 8 digit EAN code
        return '${DateTime.now().millisecondsSinceEpoch}'.substring(0, 8).padLeft(8, '0');
      case BarcodeType.CodeUPCA:
        // Generate 12 digit UPC code
        return '${DateTime.now().millisecondsSinceEpoch}'.substring(0, 12).padLeft(12, '0');
      default:
        // Generate alphanumeric code for Code128, Code39, Code93
        return 'PRD${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generator Barcode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_generatedBarcode != null)
            IconButton(
              onPressed: _copyBarcode,
              icon: const Icon(Icons.copy),
              tooltip: 'Salin Kode',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Section
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
                      'Data Barcode',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Barcode Type Selector
                    DropdownButtonFormField<BarcodeType>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Jenis Barcode',
                        prefixIcon: const Icon(Icons.qr_code),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _supportedTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                          if (_dataController.text.isNotEmpty) {
                            _generateBarcode();
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Data Input
                    TextFormField(
                      controller: _dataController,
                      decoration: InputDecoration(
                        labelText: 'Data/Kode',
                        hintText: 'Masukkan data untuk barcode',
                        prefixIcon: const Icon(Icons.text_fields),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _dataController.text = _generateRandomBarcode();
                            _generateBarcode();
                          },
                          icon: const Icon(Icons.auto_fix_high),
                          tooltip: 'Generate Random',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        // Auto-generate on typing (with debounce in real implementation)
                        if (value.isNotEmpty) {
                          _generateBarcode();
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Generate Button
                    FilledButton.icon(
                      onPressed: _generateBarcode,
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('Generate Barcode'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Barcode Display Section
            if (_generatedBarcode != null) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Barcode yang Dibuat',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Barcode Display (simplified representation)
                      Container(
                        width: double.infinity,
                        height: 100,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Barcode representation (simplified)
                            Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: List.generate(
                                  20,
                                  (index) => Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 1),
                                      decoration: BoxDecoration(
                                        color: index % 2 == 0 ? Colors.black : Colors.white,
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _generatedBarcode!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _copyBarcode,
                              icon: const Icon(Icons.copy),
                              label: const Text('Salin Kode'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop(_generatedBarcode);
                              },
                              icon: const Icon(Icons.check),
                              label: const Text('Gunakan'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Information Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Informasi Jenis Barcode',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Code128: Mendukung semua karakter ASCII\n'
                      '• Code39: Huruf, angka, dan beberapa simbol\n'
                      '• Code93: Peningkatan dari Code39\n'
                      '• EAN13: 13 digit untuk produk internasional\n'
                      '• EAN8: 8 digit untuk produk kecil\n'
                      '• UPC: 12 digit untuk produk Amerika Utara',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}