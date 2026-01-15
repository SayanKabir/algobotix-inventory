import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'theme/my_theme.dart';
import 'models/product.dart';
import 'providers/inventory_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(StockHistoryAdapter());

  // Open the Database Box
  await Hive.openBox<Product>('inventoryBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
      ],
      child: MaterialApp(
        title: 'AlgoBotix Inventory',
        debugShowCheckedModeBanner: false,
        theme: myTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}