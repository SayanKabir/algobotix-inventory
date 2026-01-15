import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/product.dart';
import '../widgets/glass_card.dart';

class StockHistoryScreen extends StatelessWidget {
  final Product product;

  const StockHistoryScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Sort history: Newest first
    final history = product.history.reversed.toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("${product.name} History"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GlassCard(
            borderRadius: 50,
            padding: EdgeInsets.zero,
            opacity: 0.8,
            onTap: () => Navigator.pop(context),
            child: const Center(child: Icon(Icons.arrow_back, color: Colors.black)),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient (Consistent with app)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF0F4F8), Color(0xFFE6E6FA), Color(0xFFF0F4F8)],
              ),
            ),
          ),

          if (history.isEmpty)
            const Center(
              child: Text(
                "No stock changes recorded yet.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final isIncrement = item.changeAmount > 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: GlassCard(
                    borderRadius: 20,
                    child: Row(
                      children: [
                        // Icon Indicator
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isIncrement
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isIncrement ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                            color: isIncrement ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Text Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isIncrement ? "Stock Added" : "Stock Removed",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM dd, yyyy - hh:mm a').format(item.date),
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        // Amount Badge
                        Text(
                          "${isIncrement ? '+' : ''}${item.changeAmount}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isIncrement ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}