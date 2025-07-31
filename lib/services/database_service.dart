import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/inventory_item.dart';
import '../models/sale_transaction.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stock_management.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Create inventory table
    await db.execute('''
      CREATE TABLE inventory (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sku TEXT UNIQUE NOT NULL,
        category TEXT NOT NULL,
        currentStock INTEGER NOT NULL,
        price REAL NOT NULL,
        lowStockThreshold INTEGER NOT NULL,
        lastUpdated INTEGER NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        itemId TEXT NOT NULL,
        itemName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unitPrice REAL NOT NULL,
        totalAmount REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (itemId) REFERENCES inventory (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_inventory_sku ON inventory(sku)');
    await db.execute('CREATE INDEX idx_inventory_category ON inventory(category)');
    await db.execute('CREATE INDEX idx_transactions_timestamp ON transactions(timestamp)');
  }

  // Inventory operations
  Future<List<InventoryItem>> getAllInventory() async {
    final db = await instance.database;
    final result = await db.query('inventory', orderBy: 'name ASC');
    return result.map((map) => InventoryItem.fromMap(map)).toList();
  }

  Future<InventoryItem?> getInventoryItem(String id) async {
    final db = await instance.database;
    final result = await db.query(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return InventoryItem.fromMap(result.first);
    }
    return null;
  }

  Future<String> insertInventoryItem(InventoryItem item) async {
    final db = await instance.database;
    await db.insert('inventory', item.toMap());
    return item.id;
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    final db = await instance.database;
    await db.update(
      'inventory',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<void> deleteInventoryItem(String id) async {
    final db = await instance.database;
    await db.delete(
      'inventory',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> skuExists(String sku, {String? excludeId}) async {
    final db = await instance.database;
    final result = await db.query(
      'inventory',
      where: excludeId != null ? 'sku = ? AND id != ?' : 'sku = ?',
      whereArgs: excludeId != null ? [sku, excludeId] : [sku],
    );
    return result.isNotEmpty;
  }

  Future<List<InventoryItem>> searchInventory(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'inventory',
      where: 'name LIKE ? OR sku LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((map) => InventoryItem.fromMap(map)).toList();
  }

  // Transaction operations
  Future<String> insertTransaction(SaleTransaction transaction) async {
    final db = await instance.database;
    await db.insert('transactions', transaction.toMap());
    return transaction.id;
  }

  Future<List<SaleTransaction>> getRecentTransactions({int limit = 10}) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return result.map((map) => SaleTransaction.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
