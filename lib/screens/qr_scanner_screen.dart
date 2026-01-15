import 'package:algobotix_inventory/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../widgets/glass_card.dart';
import 'product_details_screen.dart';
import 'add_edit_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        setState(() {
          _isProcessing = true;
        });
        _findAndNavigate(code);
        break;
      }
    }
  }

  void _findAndNavigate(String rawScannedCode) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    String searchId = rawScannedCode;
    if (rawScannedCode.length > 5) {
      searchId = rawScannedCode.substring(rawScannedCode.length - 5);
    }

    try {
      // 2. Try to find the product using the truncated 5-char ID
      final Product product = provider.products.firstWhere(
            (p) => p.id.toLowerCase() == searchId.toLowerCase(),
      );

      // Found, Go to Details
      _controller.stop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        ),
      ).then((_) {
        _resetScanner();
      });

    } catch (e) {
      // Not Found
      _controller.stop(); // Pause camera

      // _showAddDialog(rawScannedCode);
      _showAddDialog(searchId);
    }
  }

  void _resetScanner() {
    _controller.start();
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showAddDialog(String scannedId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Material(
            color: Colors.transparent,
            child: GlassCard(
              borderRadius: 30,
              opacity: 0.95,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: myPurpleColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.plus, size: 32, color: myPurpleColor),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Product Not Found",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "ID '$scannedId' is not in your inventory. Would you like to add it?",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx);
                            _resetScanner(); // Resume scanning
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Add Button
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(ctx); // Close Dialog
                            // Navigate to Add Screen with the ID
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditScreen(scannedId: scannedId),
                              ),
                            ).then((_) {
                              _resetScanner(); // Resume when they come back
                              // Refresh logic handled in AddEditScreen return
                              Provider.of<InventoryProvider>(context, listen: false).refresh();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: myPurpleColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: myPurpleColor.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: const Text("Add It", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handleBarcode),

          // Center Guide
          Center(
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: myPurpleColor, width: 4),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: myPurpleColor.withValues(alpha: 0.5),
                    blurRadius: 20, spreadRadius: 5,
                  )
                ],
              ),
            ),
          ),

          // Top Bar
          Positioned(
            top: 50, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GlassCard(
                  borderRadius: 50, padding: const EdgeInsets.all(8),
                  onTap: () => Navigator.pop(context),
                  child: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
                ),
                GlassCard(
                  borderRadius: 50, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Text("Scan Product ID", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Bottom Instruction
          Positioned(
            bottom: 80, left: 0, right: 0,
            child: Center(
              child: GlassCard(
                borderRadius: 20,
                child: const Text("Point camera at a barcode or QR code", style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}