import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/add_item_form.dart';
import '../../widgets/restock_form.dart';
import '../../widgets/edit_item_form.dart';
import '../../widgets/delete_item_form.dart';

class ManageTab extends StatefulWidget {
  const ManageTab({super.key});

  @override
  State<ManageTab> createState() => _ManageTabState();
}

class _ManageTabState extends State<ManageTab> with TickerProviderStateMixin {
  late TabController _subTabController;

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _subTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => AppTheme.warningGradient.createShader(bounds),
                    child: const Text(
                      '⚙️ Stock Management',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add new products, restock existing items, edit details, or remove items',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Sub Tab Navigation
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _subTabController,
                indicator: BoxDecoration(
                  gradient: AppTheme.warningGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.add, size: 20),
                    text: 'Add New',
                  ),
                  Tab(
                    icon: Icon(Icons.inventory, size: 20),
                    text: 'Restock',
                  ),
                  Tab(
                    icon: Icon(Icons.edit, size: 20),
                    text: 'Edit',
                  ),
                  Tab(
                    icon: Icon(Icons.delete, size: 20),
                    text: 'Delete',
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _subTabController,
                children: const [
                  AddItemForm(),
                  RestockForm(),
                  EditItemForm(),
                  DeleteItemForm(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
