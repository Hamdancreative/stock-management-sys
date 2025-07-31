import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';

class EditItemForm extends StatefulWidget {
  const EditItemForm({super.key});

  @override
  State<EditItemForm> createState() => _EditItemFormState();
}

class _EditItemFormState extends State<EditItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _priceController = TextEditingController();
  final _thresholdController = TextEditingController();
  
  InventoryItem? _selectedItem;
  String _selectedCategory = 'Electronics';
  
  final List<String> _categories = [
    'Electronics',
    'Components',
    'Tools',
    'Accessories',
    'Materials',
    'Software',
    'Hardware',
    'General',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  void _populateForm(InventoryItem item) {
    _nameController.text = item.name;
    _skuController.text = item.sku;
    _priceController.text = item.price.toString();
    _thresholdController.text = item.lowStockThreshold.toString();
    _selectedCategory = item.category;
  }

  void _clearForm() {
    _nameController.clear();
    _skuController.clear();
    _priceController.clear();
    _thresholdController.clear();
    _selectedCategory = 'Electronics';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '✏️ Edit Item Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Item Selection
                    DropdownButtonFormField<InventoryItem>(
                      value: _selectedItem,
                      decoration: const InputDecoration(
                        labelText: 'Select Item to Edit',
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
                          if (item != null) {
                            _populateForm(item);
                          } else {
                            _clearForm();
                          }
                        });
                      },
                    ),
                    
                    if (_selectedItem != null) ...[
                      const SizedBox(height: 16),
                      
                      // Current Item Info
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📝 Editing Item',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Current Stock: ${_selectedItem!.currentStock} units'),
                            const Text(
                              'Note: Stock quantity cannot be edited here - use restock/sales',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Product Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name *',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Product name is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // SKU and Category Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _skuController,
                              decoration: const InputDecoration(
                                labelText: 'SKU Code *',
                              ),
                              textCapitalization: TextCapitalization.characters,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'SKU is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Price and Threshold Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: 'Price (TZS) *',
                                prefixText: 'TZS ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Price is required';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Enter valid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _thresholdController,
                              decoration: const InputDecoration(
                                labelText: 'Low Stock Alert',
                                suffixText: 'units',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  final threshold = int.tryParse(value);
                                  if (threshold == null || threshold < 0) {
                                    return 'Enter valid threshold';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: provider.isLoading ? null : _submitEdit,
                          icon: provider.isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save),
                          label: Text(provider.isLoading ? 'Updating...' : 'Update Item'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
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
          ),
        );
      },
    );
  }

  void _submitEdit() async {
    if (_selectedItem == null || !_formKey.currentState!.validate()) return;

    final provider = context.read<InventoryProvider>();
    
    final success = await provider.updateItem(
      _selectedItem!.id,
      name: _nameController.text.trim(),
      sku: _skuController.text.trim().toUpperCase(),
      category: _selectedCategory,
      price: double.parse(_priceController.text),
      lowStockThreshold: int.tryParse(_thresholdController.text) ?? 10,
    );
    
    if (success) {
      setState(() {
        _selectedItem = null;
      });
      _clearForm();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
