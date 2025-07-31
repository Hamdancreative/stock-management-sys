import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import '../utils/currency_formatter.dart';

class RestockForm extends StatefulWidget {
  const RestockForm({super.key});

  @override
  State<RestockForm> createState() => _RestockFormState();
}

class _RestockFormState extends State<RestockForm> {
  final _quantityController = TextEditingController();
  InventoryItem? _selectedItem;
  bool _showLowStockOnly = true;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        final lowStockItems = provider.inventory
            .where((item) => item.stockStatus == StockStatus.lowStock)
            .toList();
        final displayItems = _showLowStockOnly ? lowStockItems : provider.inventory;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.inventory,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '📦 Restock Existing Item',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Low Stock Alert
                  if (lowStockItems.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '🚨 ${lowStockItems.length} item${lowStockItems.length > 1 ? 's' : ''} need restocking',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Filter Toggle
                  Row(
                    children: [
                      FilterChip(
                        label: Text('Low Stock (${lowStockItems.length})'),
                        selected: _showLowStockOnly,
                        onSelected: (selected) {
                          setState(() {
                            _showLowStockOnly = true;
                            _selectedItem = null;
                          });
                        },
                        selectedColor: Colors.orange.shade100,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Text('All Items (${provider.inventory.length})'),
                        selected: !_showLowStockOnly,
                        onSelected: (selected) {
                          setState(() {
                            _showLowStockOnly = false;
                            _selectedItem = null;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Item Selection
                  DropdownButtonFormField<InventoryItem>(
                    value: _selectedItem,
                    decoration: const InputDecoration(
                      labelText: 'Select Item to Restock',
                    ),
                    items: displayItems.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text('${item.name} (${item.sku}) - Current: ${item.currentStock} units'),
                      );
                    }).toList(),
                    onChanged: (item) {
                      setState(() {
                        _selectedItem = item;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Item Details
                  if (_selectedItem != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedItem!.stockStatus == StockStatus.lowStock
                            ? Colors.orange.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedItem!.stockStatus == StockStatus.lowStock
                              ? Colors.orange.shade200
                              : Colors.green.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📋 Item Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Name: ${_selectedItem!.name}'),
                          Text('Current Stock: ${_selectedItem!.currentStock} units'),
                          Text('Low Stock Threshold: ${_selectedItem!.lowStockThreshold} units'),
                          Text('Price: ${CurrencyFormatter.format(_selectedItem!.price)}'),
                          if (_selectedItem!.stockStatus == StockStatus.lowStock)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '⚠️ Low Stock',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                  
                  // Quantity Input
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity to Add',
                            suffixText: 'units',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Quantity is required';
                            }
                            final quantity = int.tryParse(value);
                            if (quantity == null || quantity <= 0) {
                              return 'Enter valid quantity';
                            }
                            return null;
                          },
                        ),
                      ),
                      if (_selectedItem != null && _quantityController.text.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'New Total Stock',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_selectedItem!.currentStock + (int.tryParse(_quantityController.text) ?? 0)} units',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: (_selectedItem != null && !provider.isLoading)
                          ? _submitRestock
                          : null,
                      icon: provider.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(
                        provider.isLoading
                            ? 'Restocking...'
                            : 'Add ${_quantityController.text.isEmpty ? '0' : _quantityController.text} Units',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  
                  // Error Message
                  if (provider.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.error!,
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Quick Restock for Low Stock Items
                  if (lowStockItems.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Text(
                      '🚀 Quick Restock (Low Stock Items)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...lowStockItems.take(3).map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Current: ${item.currentStock} | Min: ${item.lowStockThreshold}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedItem = item;
                                _quantityController.text = 
                                    (item.lowStockThreshold - item.currentStock + 5).toString();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: const Text('Quick Restock'),
                          ),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitRestock() async {
    if (_selectedItem == null) return;
    
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final provider = context.read<InventoryProvider>();
    final success = await provider.addStock(_selectedItem!.id, quantity);
    
    if (success) {
      _quantityController.clear();
      setState(() {
        _selectedItem = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $quantity units successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
