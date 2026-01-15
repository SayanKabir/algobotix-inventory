import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/product.dart';
import '../providers/inventory_provider.dart';
import '../widgets/glass_card.dart';
import 'add_edit_screen.dart';
import 'stock_history_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {

  late int _sessionStock;
  late int _initialStock;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initialStock = widget.product.stock;
    _sessionStock = widget.product.stock;
  }

  Future<void> _saveSessionChanges() async {
    if (_sessionStock != _initialStock) {
      final diff = _sessionStock - _initialStock;

      final provider = Provider.of<InventoryProvider>(context, listen: false);
      await provider.updateStock(widget.product, diff);

      _initialStock = _sessionStock;
    }
  }

  void _updateLocalStock(int change) {
    setState(() {
      _sessionStock += change;
      if (_sessionStock < 0) _sessionStock = 0;
      
      _hasChanges = _sessionStock != _initialStock;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // We handle the pop manually to ensure async save works
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 1. Save changes
        await _saveSessionChanges();

        // 2. Actually pop
        if (mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F4F8),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            productSliverAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Stock Control (Updates Local State Only)
                    _buildStockControl(),

                    const SizedBox(height: 24),
                    _buildDescription(),
                    const SizedBox(height: 24),
                    _buildMetadata(),
                    const SizedBox(height: 32),

                    // Navigation to History Page
                    _buildHistoryLink(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget productSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFFF0F4F8),
      flexibleSpace: FlexibleSpaceBar(
        background: widget.product.imagePath != null
            ? Image.file(
                      File(widget.product.imagePath!),
                      fit: BoxFit.cover,
                    )
            : Container(
          color: Colors.grey[300],
          child: const Center(
            child: Icon(LucideIcons.image, size: 64, color: Colors.grey),
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GlassCard(
          borderRadius: 50,
          padding: EdgeInsets.zero,
          opacity: 0.8,
          // We must trigger the PopScope logic manually
          onTap: () => Navigator.maybePop(context),
          child: const Center(child: Icon(Icons.arrow_back, color: Colors.black)),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: GlassCard(
            borderRadius: 50,
            padding: EdgeInsets.zero,
            opacity: 0.8,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditScreen(product: widget.product),
                ),
              ).then((_) {
                // Refresh if they edited details (Name/Desc)
                // Note: Stock changes from Edit Screen will also sync here
                setState(() {
                  _initialStock = widget.product.stock;
                  _sessionStock = widget.product.stock;
                });
                Provider.of<InventoryProvider>(context, listen: false).refresh();
              });
            },
            child: const SizedBox(
              width: 40, height: 40,
              child: Icon(LucideIcons.edit, color: Colors.black, size: 20),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GlassCard(
            borderRadius: 50,
            padding: EdgeInsets.zero,
            opacity: 0.8,
            onTap: () => _confirmDelete(),
            child: const SizedBox(
              width: 40, height: 40,
              child: Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStockControl() {
    return GlassCard(
      borderRadius: 30,
      borderColor: _hasChanges ? const Color(0xFF6C63FF).withValues(alpha: 0.5) : null,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stockButton(
                icon: LucideIcons.minus,
                color: Colors.redAccent,
                onTap: () => _updateLocalStock(-1),
              ),
              Column(
                children: [
                  Text(
                      _hasChanges ? "Unsaved Stock" : "Current Stock",
                      style: TextStyle(
                          color: _hasChanges ? const Color(0xFF6C63FF) : Colors.grey,
                          fontWeight: _hasChanges ? FontWeight.bold : FontWeight.normal
                      )
                  ),
                  Text(
                    "$_sessionStock",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              _stockButton(
                icon: LucideIcons.plus,
                color: const Color(0xFF6C63FF),
                onTap: () => _updateLocalStock(1),
              ),
            ],
          ),
          if (_hasChanges)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Changes saved automatically on exit",
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildHistoryLink(BuildContext context) {
    return GlassCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StockHistoryScreen(product: widget.product),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.history, color: Color(0xFF6C63FF)),
              SizedBox(width: 12),
              Text(
                "View Stock History",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          Icon(LucideIcons.chevronRight, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _stockButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.product.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
        ),
        GlassCard(
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          opacity: 0.5,
          child: Text(
            "ID: ${widget.product.id}",
            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(widget.product.description, style: const TextStyle(fontSize: 16, height: 1.5)),
      ],
    );
  }

  Widget _buildMetadata() {
    final dateStr = DateFormat('MMM dd, yyyy - hh:mm a').format(widget.product.dateAdded);

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16.0,    // Horizontal gap between the "User" group and "Clock" group
      runSpacing: 4.0,  // Vertical gap if it wraps to a new line
      children: [
        // Group 1: User (Icon + Name)
        Row(
          mainAxisSize: MainAxisSize.min, // Takes only needed space
          children: [
            Icon(LucideIcons.user, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            // Flexible allows name to shrink if needed, preventing overflow even inside the wrap
            Flexible(
              child: Text(
                widget.product.addedBy,
                style: TextStyle(color: Colors.grey[600]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Group 2: Time (Icon + Date)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.clock, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(dateStr, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  void _confirmDelete() {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (ctx) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Material(
            color: Colors.transparent,
            child: GlassCard(
              borderRadius: 30, opacity: 0.95, padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.alertTriangle, size: 32, color: Colors.redAccent),
                  ),
                  const SizedBox(height: 16),
                  const Text("Delete Product?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text(
                      "This action cannot be undone.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
                            child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            provider.deleteProduct(widget.product.key);
                            Navigator.pop(ctx); // Close dialog
                            Navigator.pop(context); // Close details
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
                            child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
}