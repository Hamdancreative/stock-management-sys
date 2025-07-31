import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import '../utils/currency_formatter.dart';

class DeleteItemForm extends StatefulWidget {
  const DeleteItemForm({super.key});

  @override
  State<DeleteItemForm> createState() => _DeleteItemFormState();
}

class _DeleteItemFormState extends State<DeleteItemForm> {
  InventoryItem? _selectedItem;
  bool _showConfirmDialog = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
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
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '🗑️ Delete Item',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Warning Message
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red.shade600),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            '⚠️ Warning: Deleting an item will permanently remove it from your inventory. This action cannot be undone.',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Item Selection
                  DropdownButtonFormField<InventoryItem>(
                    value: _selectedItem,
                    decoration: const InputDecoration(
                      labelText: 'Select Item to Delete',
                    ),
                    items: provider.inventory.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text('${item.name} (${item.sku}) - Stock: ${item.currentStock}'),
                      );
                    }).toList(),
                    onChanged: (item) {
                      setState(() {
                        _selectedItem = item;
                      });
                    },
                  ),
                  
                  if (_selectedItem != null) ...[
                    const SizedBox(height: 24),
                    
                    // Item Details to be Deleted
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🗑️ Item to be deleted:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text('Name: ${_selectedItem!.name}'),
                          Text('SKU: ${_selectedItem!.sku}'),
                          Text('Current Stock: ${_selectedItem!.currentStock} units'),
                          Text('Price: ${CurrencyFormatter.format(_selectedItem!.price)}'),
                          Text('Category: ${_selectedItem!.category}'),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Delete Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: provider.isLoading ? null : _showDeleteConfirmation,
                        icon: provider.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.delete_forever),
                        label: Text(provider.isLoading ? 'Deleting...' : 'Delete Item'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                  
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    if (_selectedItem == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Confirm Deletion'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this item?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${_selectedItem!.name}'),
                  Text('SKU: ${_selectedItem!.sku}'),
                  Text('Current Stock: ${_selectedItem!.currentStock} units'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '⚠️ This action cannot be undone!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _confirmDelete,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() async {
    if (_selectedItem == null) return;

    Navigator.of(context).pop(); // Close dialog

    final provider = context.read<InventoryProvider>();
    final success = await provider.deleteItem(_selectedItem!.id);
    
    if (success) {
      setState(() {
        _selectedItem = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
