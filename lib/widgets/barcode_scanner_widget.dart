import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onBarcodeScanned;
  final String? title;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeScanned,
    this.title,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  MobileScannerController controller = MobileScannerController();
  bool _flashOn = false;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) {
        _showPermissionDialog();
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Izin Kamera Diperlukan'),
          content: const Text(
            'Aplikasi memerlukan akses kamera untuk scan barcode. Silakan berikan izin di pengaturan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Buka Pengaturan'),
            ),
          ],
        );
      },
    );
  }

  void _onDetect(BarcodeCapture barcodeCapture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
        });
        
        // Vibrate or provide feedback
        // HapticFeedback.mediumImpact();
        
        widget.onBarcodeScanned(barcode.rawValue!);
        Navigator.of(context).pop();
        break;
      }
    }
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });
    controller.toggleTorch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Scan Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          // Overlay
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.primary,
                borderRadius: 16,
                borderLength: 30,
                borderWidth: 4,
                cutOutSize: 250,
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Arahkan kamera ke barcode',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pastikan barcode terlihat jelas dalam kotak',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Manual Input Button
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: OutlinedButton.icon(
                onPressed: _showManualInputDialog,
                icon: const Icon(Icons.keyboard, color: Colors.white),
                label: const Text(
                  'Input Manual',
                  style: TextStyle(color: Colors.white),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog() {
    final TextEditingController barcodeController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Input Barcode Manual'),
          content: TextField(
            controller: barcodeController,
            decoration: const InputDecoration(
              labelText: 'Kode Barcode',
              hintText: 'Masukkan kode barcode',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                widget.onBarcodeScanned(value);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final barcode = barcodeController.text.trim();
                if (barcode.isNotEmpty) {
                  widget.onBarcodeScanned(barcode);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// Custom overlay shape for QR scanner
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    Path getRightTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.right - borderRadius, rect.top)
        ..quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + borderRadius)
        ..lineTo(rect.right, rect.bottom);
    }

    Path getRightBottomPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.right - borderRadius, rect.bottom)
        ..quadraticBezierTo(rect.right, rect.bottom, rect.right, rect.bottom - borderRadius)
        ..lineTo(rect.right, rect.top);
    }

    Path getLeftBottomPath(Rect rect) {
      return Path()
        ..moveTo(rect.right, rect.bottom)
        ..lineTo(rect.left + borderRadius, rect.bottom)
        ..quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.bottom - borderRadius)
        ..lineTo(rect.left, rect.top);
    }

    final width = rect.width;
    final height = rect.height;
    final borderWidthSize = width / 2;
    final borderHeightSize = height / 2;
    final cutOutWidth = cutOutSize < width ? cutOutSize : width - borderWidth;
    final cutOutHeight = cutOutSize < height ? cutOutSize : height - borderWidth;

    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutWidth,
      height: cutOutHeight,
    );

    final cutOutLeftTopPath = getLeftTopPath(cutOutRect);
    final cutOutRightTopPath = getRightTopPath(cutOutRect);
    final cutOutRightBottomPath = getRightBottomPath(cutOutRect);
    final cutOutLeftBottomPath = getLeftBottomPath(cutOutRect);

    return Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        ),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final cutOutWidth = cutOutSize < width ? cutOutSize : width - borderWidth;
    final cutOutHeight = cutOutSize < height ? cutOutSize : height - borderWidth;

    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: cutOutWidth,
      height: cutOutHeight,
    );

    final paint = Paint()..color = borderColor;
    final radius = Radius.circular(borderRadius);
    final rrect = RRect.fromRectAndRadius(cutOutRect, radius);

    // Draw border corners
    const cornerLength = 20.0;
    
    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(rrect.left, rrect.top + cornerLength)
        ..lineTo(rrect.left, rrect.top + borderRadius)
        ..quadraticBezierTo(rrect.left, rrect.top, rrect.left + borderRadius, rrect.top)
        ..lineTo(rrect.left + cornerLength, rrect.top),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(rrect.right - cornerLength, rrect.top)
        ..lineTo(rrect.right - borderRadius, rrect.top)
        ..quadraticBezierTo(rrect.right, rrect.top, rrect.right, rrect.top + borderRadius)
        ..lineTo(rrect.right, rrect.top + cornerLength),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(rrect.right, rrect.bottom - cornerLength)
        ..lineTo(rrect.right, rrect.bottom - borderRadius)
        ..quadraticBezierTo(rrect.right, rrect.bottom, rrect.right - borderRadius, rrect.bottom)
        ..lineTo(rrect.right - cornerLength, rrect.bottom),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );

    // Bottom left corner
    canvas.drawPath(
      Path()
        ..moveTo(rrect.left + cornerLength, rrect.bottom)
        ..lineTo(rrect.left + borderRadius, rrect.bottom)
        ..quadraticBezierTo(rrect.left, rrect.bottom, rrect.left, rrect.bottom - borderRadius)
        ..lineTo(rrect.left, rrect.bottom - cornerLength),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}