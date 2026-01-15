import 'dart:io';
import 'dart:ui';
import 'package:algobotix_inventory/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/inventory_provider.dart';
import '../models/product.dart';
import '../widgets/glass_card.dart';
import 'add_edit_screen.dart';
import 'product_details_screen.dart';
import 'qr_scanner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Soft Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: backgroundGradient,
            ),
          ),

          // Background Orb
          Positioned(
            top: -100,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: myPurpleColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                mySearchBar(context),
                Expanded(child: _buildProductList(context)),
              ],
            ),
          ),

          // 2. Colored Floating Centered Button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddEditScreen()),
                  ).then((_) {
                    // FIX: Refresh provider when coming back from Add Screen
                    Provider.of<InventoryProvider>(context, listen: false).refresh();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: myPurpleColor,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: myPurpleColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.plus, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        "Add New Item",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "AlgoBotix Inventory",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          GlassCard(
            borderRadius: 50,
            padding: const EdgeInsets.all(10),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScannerScreen()),
              );
            },
            child: const Icon(LucideIcons.scanLine, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget mySearchBar(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        borderRadius: 50,
        child: TextField(
          decoration: const InputDecoration(
            hintText: "Search by Product ID...",
            border: InputBorder.none,
            icon: Icon(LucideIcons.search, color: Colors.grey),
          ),
          onChanged: (value) {
            provider.search(value);
          },
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final products = provider.products;

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.box, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  "No inventory found",
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ],
            ),
          );
        }

        // 3. IMPLEMENTED: RefreshIndicator & BouncingScrollPhysics
        return RefreshIndicator(
          color: const Color(0xFF6C63FF),
          onRefresh: () async {
            provider.refresh(); // Manual Pull-to-Refresh
          },
          child: ListView.builder(
            // Bouncing Physics
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ProductItem(product: product),
              );
            },
          ),
        );
      },
    );
  }
}

class _ProductItem extends StatelessWidget {
  final Product product;

  const _ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        ).then((_) {
          // FIX: Refresh provider when returning from Details (which might lead to Edit)
          Provider.of<InventoryProvider>(context, listen: false).refresh();
        });
      },
      child: Row(
        children: [
          // Image Thumbnail
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
              image: product.imagePath != null
                  ? DecorationImage(
                image: FileImage(File(product.imagePath!)),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: product.imagePath == null
                ? const Icon(LucideIcons.image, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "ID: ${product.id}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Stock Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: product.stock < 10
                  ? Colors.red.withValues(alpha: 0.1)
                  : myPurpleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${product.stock} Left",
              style: TextStyle(
                color: product.stock < 10 ? Colors.red : myPurpleColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}