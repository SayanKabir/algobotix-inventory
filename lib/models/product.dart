import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 0)
class Product extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  int stock;

  @HiveField(4)
  String? imagePath;

  @HiveField(5)
  DateTime dateAdded;

  @HiveField(6)
  String addedBy;

  @HiveField(7)
  List<StockHistory> history;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.stock,
    this.imagePath,
    required this.dateAdded,
    required this.addedBy,
    this.history = const [],
  });
}

@HiveType(typeId: 1)
class StockHistory {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int changeAmount;

  @HiveField(2)
  String type;

  StockHistory({
    required this.date,
    required this.changeAmount,
    required this.type,
  });
}