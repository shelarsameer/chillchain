import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/product.dart';
import '../../models/storage.dart';
import '../../providers/product_provider.dart';
import '../../providers/storage_provider.dart';
import '../../widgets/product_card.dart';

class ColdStorageMarketplaceScreen extends StatefulWidget {
  const ColdStorageMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<ColdStorageMarketplaceScreen> createState() => _ColdStorageMarketplaceScreenState();
}

class _ColdStorageMarketplaceScreenState extends State<ColdStorageMarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<StoredItem> _filteredItems = [];
  String? _selectedCategory;
  TemperatureZone? _selectedZone;

  @override
  void initState() {
    super.initState();
    _loadMarketplaceItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketplaceItems() async {
    final storageProvider = Provider.of<StorageProvider>(context, listen: false);
    await storageProvider.fetchStoredItems();
    setState(() {
      _filteredItems = storageProvider.storedItems;
    });
  }

  void _filterItems() {
    final storageProvider = Provider.of<StorageProvider>(context, listen: false);
    final searchTerm = _searchController.text.toLowerCase();
    
    setState(() {
      _filteredItems = storageProvider.storedItems.where((item) {
        final matchesSearch = searchTerm.isEmpty || 
          item.productName.toLowerCase().contains(searchTerm) ||
          item.category.toLowerCase().contains(searchTerm);
          
        final matchesCategory = _selectedCategory == null || 
          item.category == _selectedCategory;
          
        final matchesZone = _selectedZone == null;  // We don't have temperature zone in StoredItem
        
        return matchesSearch && matchesCategory && matchesZone;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storageProvider = Provider.of<StorageProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching 
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (query) {
                  _filterItems();
                },
              )
            : const Text('Cold Storage Marketplace'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _filterItems();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to cart
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMarketplaceItems,
        child: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: storageProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                  ? _buildEmptyState()
                  : _buildProductGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final categories = Provider.of<StorageProvider>(context)
      .storedItems
      .map((item) => item.category)
      .toSet()
      .toList();
      
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          DropdownButton<String>(
            hint: const Text('Category'),
            value: _selectedCategory,
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
                _filterItems();
              });
            },
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Categories'),
              ),
              ...categories.map((category) => DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              )),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(child: Container()),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Products'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Temperature Zone'),
                  Wrap(
                    spacing: 8.0,
                    children: TemperatureZone.values.map((zone) {
                      final zoneInfo = AppConstants.temperatureZones[zone.toString().split('.').last.toLowerCase()];
                      return FilterChip(
                        selected: _selectedZone == zone,
                        label: Text(zoneInfo?['name'] ?? zone.toString().split('.').last),
                        onSelected: (selected) {
                          setState(() {
                            _selectedZone = selected ? zone : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _filterItems();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (ctx, index) {
        final item = _filteredItems[index];
        return _buildStoredItemCard(item);
      },
    );
  }

  Widget _buildStoredItemCard(StoredItem item) {
    final daysRemaining = item.expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysRemaining < 7;
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showItemDetailDialog(item);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image or placeholder
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.inventory_2, size: 40, color: Colors.grey),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: ${item.category}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantity: ${item.quantity.toStringAsFixed(1)} kg',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expires in $daysRemaining days',
                        style: TextStyle(
                          color: isExpiringSoon ? Colors.red : Colors.grey[600],
                          fontSize: 11,
                          fontWeight: isExpiringSoon ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const Icon(Icons.shopping_cart_outlined, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetailDialog(StoredItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item.productName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Category: ${item.category}'),
                const SizedBox(height: 8),
                Text('Quantity: ${item.quantity.toStringAsFixed(1)} kg'),
                const SizedBox(height: 8),
                Text('Expiry Date: ${item.expiryDate.toString().substring(0, 10)}'),
                const SizedBox(height: 8),
                Text('Storage Type: ${item.bookingType.toString().split('.').last}'),
                const SizedBox(height: 16),
                const Text('This product is stored in a cold storage facility and is available for purchase.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Add to cart logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.productName} added to cart')),
                );
              },
              child: const Text('Add to Cart'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are currently no products stored in\ncold storage facilities available for purchase.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMarketplaceItems,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
} 