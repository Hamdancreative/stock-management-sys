import 'package:flutter/material.dart';
// ...existing code...


class InventoryItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final int currentStock;
  final double price;
  final int lowStockThreshold;
  final DateTime lastUpdated;

  InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.currentStock,
    required this.price,
    required this.lowStockThreshold,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'category': category,
      'currentStock': currentStock,
      'price': price,
      'lowStockThreshold': lowStockThreshold,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      name: map['name'],
      sku: map['sku'],
      category: map['category'],
      currentStock: map['currentStock'],
      price: map['price'].toDouble(),
      lowStockThreshold: map['lowStockThreshold'],
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated']),
    );
  }

  InventoryItem copyWith({
    String? id,
    String? name,
    String? sku,
    String? category,
    int? currentStock,
    double? price,
    int? lowStockThreshold,
    DateTime? lastUpdated,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      currentStock: currentStock ?? this.currentStock,
      price: price ?? this.price,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  StockStatus get stockStatus {
    if (currentStock == 0) {
      return StockStatus.outOfStock;
    } else if (currentStock <= lowStockThreshold) {
      return StockStatus.lowStock;
    } else {
      return StockStatus.inStock;
    }
  }
}

enum StockStatus {
  inStock,
  lowStock,
  outOfStock,
}

extension StockStatusExtension on StockStatus {
  String get label {
    switch (this) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  Color get color {
    switch (this) {
      case StockStatus.inStock:
        return const Color(0xFF10B981);
      case StockStatus.lowStock:
        return const Color(0xFFF59E0B);
      case StockStatus.outOfStock:
        return const Color(0xFFEF4444);
    }
  }

  String get icon {
    switch (this) {
      case StockStatus.inStock:
        return '🟢';
      case StockStatus.lowStock:
        return '🟡';
      case StockStatus.outOfStock:
        return '🔴';
    }
  }
}
