import 'package:flutter/foundation.dart';
import '../models/inventory_item.dart';
import '../models/sale_transaction.dart';
import '../models/cart_item.dart';
import '../services/inventory_service.dart';

class InventoryProvider with ChangeNotifier {
  List<InventoryItem> _inventory = [];
  List<SaleTransaction> _transactions = [];
  List<CartItem> _cart = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<InventoryItem> get inventory => _inventory;
  List<SaleTransaction> get transactions => _transactions;
  List<CartItem> get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Inventory statistics
  int get totalItems => _inventory.length;
  int get lowStockItems => _inventory.where((item) => item.stockStatus == StockStatus.lowStock).length;
  int get outOfStockItems => _inventory.where((item) => item.stockStatus == StockStatus.outOfStock).length;
  double get totalValue => _inventory.fold(0, (sum, item) => sum + (item.currentStock * item.price));

  // Available items for sale
  List<InventoryItem> get availableItems => _inventory.where((item) => item.currentStock > 0).toList();

  // Cart statistics
  int get cartItemCount => _cart.length;
  int get cartTotalQuantity => _cart.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cart.fold(0, (sum, item) => sum + item.subtotal);

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Load inventory
  Future<void> loadInventory() async {
    _setLoading(true);
    _setError(null);
    
    try {
      _inventory = await InventoryService.getInventory();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load transactions
  Future<void> loadTransactions() async {
    try {
      _transactions = await InventoryService.getRecentTransactions();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Add new item
  Future<bool> addNewItem({
    required String name,
    required String sku,
    required String category,
    required int currentStock,
    required double price,
    required int lowStockThreshold,
  }) async {
    _setError(null);
    
    try {
      await InventoryService.addNewItem(
        name: name,
        sku: sku,
        category: category,
        currentStock: currentStock,
        price: price,
        lowStockThreshold: lowStockThreshold,
      );
      await loadInventory();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Update item
  Future<bool> updateItem(
    String itemId, {
    String? name,
    String? sku,
    String? category,
    double? price,
    int? lowStockThreshold,
  }) async {
    _setError(null);
    
    try {
      await InventoryService.updateItem(
        itemId,
        name: name,
        sku: sku,
        category: category,
        price: price,
        lowStockThreshold: lowStockThreshold,
      );
      await loadInventory();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Add stock to existing item
  Future<bool> addStock(String itemId, int quantity) async {
    _setError(null);
    
    try {
      await InventoryService.addStock(itemId, quantity);
      await loadInventory();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Delete item
  Future<bool> deleteItem(String itemId) async {
    _setError(null);
    
    try {
      await InventoryService.deleteItem(itemId);
      await loadInventory();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Cart operations
  void addToCart(InventoryItem item, int quantity) {
    final existingIndex = _cart.indexWhere((cartItem) => cartItem.item.id == item.id);
    
    if (existingIndex >= 0) {
      final existingItem = _cart[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      
      if (newQuantity <= item.currentStock) {
        _cart[existingIndex] = existingItem.copyWith(quantity: newQuantity);
      } else {
        _setError('Only ${item.currentStock} units available');
        return;
      }
    } else {
      if (quantity <= item.currentStock) {
        _cart.add(CartItem(item: item, quantity: quantity));
      } else {
        _setError('Only ${item.currentStock} units available');
        return;
      }
    }
    
    _setError(null);
    notifyListeners();
  }

  void updateCartItemQuantity(String itemId, int quantity) {
    final index = _cart.indexWhere((cartItem) => cartItem.item.id == itemId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        final item = _cart[index].item;
        if (quantity <= item.currentStock) {
          _cart[index] = _cart[index].copyWith(quantity: quantity);
        } else {
          _setError('Only ${item.currentStock} units available');
          return;
        }
      }
      _setError(null);
      notifyListeners();
    }
  }

  void removeFromCart(String itemId) {
    _cart.removeWhere((cartItem) => cartItem.item.id == itemId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // Process sale
  Future<bool> processSale() async {
    if (_cart.isEmpty) {
      _setError('Cart is empty');
      return false;
    }

    _setError(null);
    
    try {
      for (final cartItem in _cart) {
        await InventoryService.sellItem(cartItem.item.id, cartItem.quantity);
      }
      
      _cart.clear();
      await loadInventory();
      await loadTransactions();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Search inventory
  Future<List<InventoryItem>> searchInventory(String query) async {
    try {
      return await InventoryService.searchInventory(query);
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  // Get low stock items
  Future<List<InventoryItem>> getLowStockItems() async {
    try {
      return await InventoryService.getLowStockItems();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }
}
