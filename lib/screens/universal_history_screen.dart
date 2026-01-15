import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/inventory_provider.dart';
import '../models/product.dart'; // Needed for StockHistory model
import '../widgets/glass_card.dart';

class UniversalHistoryScreen extends StatelessWidget {
  const UniversalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Global Activity Log"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GlassCard(
            borderRadius: 50,
            padding: EdgeInsets.zero,
            opacity: 0.8,
            onTap: () => Navigator.pop(context),
            child: const Center(
                child: Icon(Icons.arrow_back, color: Colors.black)),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Consistent Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF0F4F8), // Soft Cloud White
                  Color(0xFFE6E6FA), // Very Light Lavender
                  Color(0xFFF0F4F8),
                ],
              ),
            ),
          ),

          // 2. The History List
          Consumer<InventoryProvider>(
            builder: (context, provider, child) {
              final history = provider.allHistory;

              if (history.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.history, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        "No activity recorded yet.",
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                // Add padding to top to avoid overlap with AppBar
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                physics: const BouncingScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final entry = history[index];

                  // Extract data from the Map created in Provider
                  final StockHistory record = entry['record'];
                  final String name = entry['productName'];
                  final String? imagePath = entry['productImage'];

                  final bool isIncrement = record.changeAmount > 0;
                  final Color statusColor = isIncrement ? Colors.green : Colors.red;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GlassCard(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // 1. Product Thumbnail
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              image: imagePath != null
                                  ? DecorationImage(
                                image: FileImage(File(imagePath)),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: imagePath == null
                                ? const Icon(LucideIcons.image,
                                size: 20, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 16),

                          // 2. Text Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(LucideIcons.clock, size: 12, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MMM dd • hh:mm a').format(record.date),
                                      style: TextStyle(
                                          color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 3. Change Indicator Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isIncrement
                                      ? LucideIcons.trendingUp
                                      : LucideIcons.trendingDown,
                                  size: 14,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "${isIncrement ? '+' : ''}${record.changeAmount}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}