class SaleTransaction {
  final String id;
  final String itemId;
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final DateTime timestamp;

  SaleTransaction({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SaleTransaction.fromMap(Map<String, dynamic> map) {
    return SaleTransaction(
      id: map['id'],
      itemId: map['itemId'],
      itemName: map['itemName'],
      quantity: map['quantity'],
      unitPrice: map['unitPrice'].toDouble(),
      totalAmount: map['totalAmount'].toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
    );
  }
}
