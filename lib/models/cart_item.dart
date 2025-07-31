import 'inventory_item.dart';

class CartItem {
  final InventoryItem item;
  final int quantity;

  CartItem({
    required this.item,
    required this.quantity,
  });

  double get subtotal => item.price * quantity;

  CartItem copyWith({
    InventoryItem? item,
    int? quantity,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}
