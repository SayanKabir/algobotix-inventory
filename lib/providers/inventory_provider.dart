import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class InventoryProvider extends ChangeNotifier {

  final Box<Product> _box = Hive.box<Product>('inventoryBox');

  String _searchQuery = "";
  String _currentUsername = "Admin";

  InventoryProvider() {
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUsername = prefs.getString('username') ?? "AlgoBotix_Staff_01";
    notifyListeners();
  }

  String get currentUsername => _currentUsername;

  List<Product> get products {
    final allProducts = _box.values.toList();

    if (_searchQuery.isEmpty) {
      return allProducts;
    } else {
      // Filter by Product ID
      return allProducts
          .where((p) => p.id.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  List<Map<String, dynamic>> get allHistory {
    List<Map<String, dynamic>> globalLog = [];

    for (var product in _box.values) {
      for (var record in product.history) {
        globalLog.add({
          'productName': product.name,
          'productImage': product.imagePath,
          'record': record,
        });
      }
    }

    // Sort by Date Descending (Newest first)
    globalLog.sort((a, b) {
      final recordA = a['record'] as StockHistory;
      final recordB = b['record'] as StockHistory;
      return recordB.date.compareTo(recordA.date);
    });

    return globalLog;
  }

  // Search Logic
  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    // Product ID must be unique
    if (_box.values.any((p) => p.id == product.id)) {
      throw Exception("Product ID ${product.id} already exists.");
    }

    await _box.add(product);
    notifyListeners();
  }

  Future<void> updateProduct(dynamic key, Product updatedProduct) async {
    await _box.put(key, updatedProduct);
    notifyListeners();
  }

  Future<void> deleteProduct(dynamic key) async {
    await _box.delete(key);
    notifyListeners();
  }

  Future<void> updateStock(Product product, int change) async {
    product.stock += change;

    // Create history log entry
    final historyItem = StockHistory(
      date: DateTime.now(),
      changeAmount: change,
      type: change > 0 ? "Increment" : "Decrement",
    );

    // We must re-assign the list for Hive to detect the change in a nested object
    List<StockHistory> newHistory = List.from(product.history)..add(historyItem);
    product.history = newHistory;

    // Save the specific HiveObject
    await product.save();
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }
}