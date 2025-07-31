import 'package:uuid/uuid.dart';
import '../models/inventory_item.dart';
import '../models/sale_transaction.dart';
import 'database_service.dart';

class InventoryService {
  static final DatabaseService _db = DatabaseService.instance;
  static const Uuid _uuid = Uuid();

  // Get all inventory items
  static Future<List<InventoryItem>> getInventory() async {
    try {
      return await _db.getAllInventory();
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  // Add new inventory item
  static Future<String> addNewItem({
    required String name,
    required String sku,
    required String category,
    required int currentStock,
    required double price,
    required int lowStockThreshold,
  }) async {
    try {
      // Check for duplicate SKU
      if (await _db.skuExists(sku)) {
        throw Exception('SKU already exists');
      }

      final item = InventoryItem(
        id: _uuid.v4(),
        name: name,
        sku: sku.toUpperCase(),
        category: category,
        currentStock: currentStock,
        price: price,
        lowStockThreshold: lowStockThreshold,
        lastUpdated: DateTime.now(),
      );

      await _db.insertInventoryItem(item);
      return item.id;
    } catch (e) {
      throw Exception('Failed to add new item: $e');
    }
  }

  // Update existing item (except current stock)
  static Future<void> updateItem(
    String itemId, {
    String? name,
    String? sku,
    String? category,
    double? price,
    int? lowStockThreshold,
  }) async {
    try {
      final existingItem = await _db.getInventoryItem(itemId);
      if (existingItem == null) {
        throw Exception('Item not found');
      }

      // Check for duplicate SKU if SKU is being updated
      if (sku != null && sku != existingItem.sku) {
        if (await _db.skuExists(sku, excludeId: itemId)) {
          throw Exception('SKU already exists');
        }
      }

      final updatedItem = existingItem.copyWith(
        name: name,
        sku: sku?.toUpperCase(),
        category: category,
        price: price,
        lowStockThreshold: lowStockThreshold,
        lastUpdated: DateTime.now(),
      );

      await _db.updateInventoryItem(updatedItem);
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
  }

  // Add stock to existing item
  static Future<void> addStock(String itemId, int quantity) async {
    if (quantity <= 0) {
      throw Exception('Quantity must be positive');
    }

    try {
      final item = await _db.getInventoryItem(itemId);
      if (item == null) {
        throw Exception('Item not found');
      }

      final updatedItem = item.copyWith(
        currentStock: item.currentStock + quantity,
        lastUpdated: DateTime.now(),
      );

      await _db.updateInventoryItem(updatedItem);
    } catch (e) {
      throw Exception('Failed to add stock: $e');
    }
  }

  // Sell item (reduce stock)
  static Future<void> sellItem(String itemId, int quantity) async {
    if (quantity <= 0) {
      throw Exception('Quantity must be positive');
    }

    try {
      final item = await _db.getInventoryItem(itemId);
      if (item == null) {
        throw Exception('Item not found');
      }

      if (item.currentStock < quantity) {
        throw Exception('Insufficient stock');
      }

      // Update inventory
      final updatedItem = item.copyWith(
        currentStock: item.currentStock - quantity,
        lastUpdated: DateTime.now(),
      );
      await _db.updateInventoryItem(updatedItem);

      // Create transaction record
      final transaction = SaleTransaction(
        id: _uuid.v4(),
        itemId: itemId,
        itemName: item.name,
        quantity: quantity,
        unitPrice: item.price,
        totalAmount: item.price * quantity,
        timestamp: DateTime.now(),
      );
      await _db.insertTransaction(transaction);
    } catch (e) {
      throw Exception('Failed to process sale: $e');
    }
  }

  // Delete inventory item
  static Future<void> deleteItem(String itemId) async {
    try {
      final item = await _db.getInventoryItem(itemId);
      if (item == null) {
        throw Exception('Item not found');
      }

      await _db.deleteInventoryItem(itemId);
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  // Get low stock items
  static Future<List<InventoryItem>> getLowStockItems() async {
    try {
      final items = await _db.getAllInventory();
      return items.where((item) => item.currentStock <= item.lowStockThreshold).toList();
    } catch (e) {
      throw Exception('Failed to fetch low stock items: $e');
    }
  }

  // Get recent transactions
  static Future<List<SaleTransaction>> getRecentTransactions({int limit = 10}) async {
    try {
      return await _db.getRecentTransactions(limit: limit);
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  // Search inventory
  static Future<List<InventoryItem>> searchInventory(String query) async {
    try {
      return await _db.searchInventory(query);
    } catch (e) {
      throw Exception('Failed to search inventory: $e');
    }
  }
}
