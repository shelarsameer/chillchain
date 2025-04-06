import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/app_constants.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/temperature_utils.dart';
import 'add_edit_product_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _products = [];
  String _searchQuery = '';
  String? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      await productProvider.fetchVendorProducts(authProvider.currentUser!.id);
      
      setState(() {
        _products = productProvider.products
            .where((product) => product.vendorId == authProvider.currentUser!.id)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load products: ${e.toString()}';
      });
    }
  }
  
  List<Product> get filteredProducts {
    return _products.where((product) {
      // Apply search filter
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Apply category filter
      final matchesCategory = _selectedCategory == null || product.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }
  
  Future<void> _addNewProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditProductScreen(),
      ),
    );
    
    if (result == true) {
      _loadProducts(); // Refresh the list if a product was added
    }
  }
  
  Future<void> _editProduct(Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditProductScreen(product: product),
      ),
    );
    
    if (result == true) {
      _loadProducts(); // Refresh the list if a product was updated
    }
  }
  
  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await productProvider.deleteProduct(product.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} deleted'),
          backgroundColor: Colors.green,
        ),
      );
      
      await _loadProducts();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to delete product: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _updateStock(Product product, int newStock) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final updatedProduct = product.copyWith(stockQuantity: newStock);
      await productProvider.updateProduct(updatedProduct);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} stock updated to $newStock'),
          backgroundColor: Colors.green,
        ),
      );
      
      await _loadProducts();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to update stock: ${e.toString()}';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return _isLoading && _products.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildCategoryChip(null, 'All'),
                        _buildCategoryChip('Dairy', 'Dairy'),
                        _buildCategoryChip('Meat', 'Meat'),
                        _buildCategoryChip('Seafood', 'Seafood'),
                        _buildCategoryChip('Fruits', 'Fruits'),
                        _buildCategoryChip('Vegetables', 'Vegetables'),
                        _buildCategoryChip('Frozen Foods', 'Frozen'),
                        _buildCategoryChip('Bakery', 'Bakery'),
                        _buildCategoryChip('Beverages', 'Beverages'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProducts,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                : filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _products.isEmpty
                              ? 'No products in your inventory'
                              : 'No products match your search',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_products.isEmpty)
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddEditProductScreen(),
                                  ),
                                ).then((_) => _loadProducts());
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add Product'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadProducts,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _buildProductCard(product);
                        },
                      ),
                    ),
            ),
          ],
        );
  }
  
  Widget _buildCategoryChip(String? category, String label) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
      ),
    );
  }
  
  Widget _buildProductCard(Product product) {
    final isLowStock = product.stockQuantity < 10;
    final isOutOfStock = product.stockQuantity <= 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl ?? 'https://placehold.co/400x300/EAEAEA/CCCCCC?text=No+Image',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Stock: ${product.stockQuantity}',
                        style: TextStyle(
                          color: isOutOfStock
                              ? Colors.red
                              : isLowStock
                                  ? Colors.orange
                                  : Colors.grey.shade700,
                          fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isLowStock && !isOutOfStock)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 16,
                          ),
                        ),
                      if (isOutOfStock)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: ${product.category}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditProductScreen(product: product),
                      ),
                    ).then((_) => _loadProducts());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () => _deleteProduct(product),
                ),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () => _showStockUpdateDialog(product),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showStockUpdateDialog(Product product) {
    final stockController = TextEditingController(text: product.stockQuantity.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Product: ${product.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              decoration: const InputDecoration(
                labelText: 'Stock Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null && newStock >= 0) {
                Navigator.pop(context);
                _updateStock(product, newStock);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid quantity'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
} 