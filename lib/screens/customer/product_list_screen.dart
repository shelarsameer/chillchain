import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../utils/temperature_utils.dart';
import '../../widgets/product_card.dart';
import '../../widgets/custom_product_card.dart';
import '../../widgets/product_card_fixer.dart';
import '../../providers/order_provider.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String? _categoryFilter;
  TemperatureZone? _zoneFilter;
  bool _isLoading = false;
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      if (args.containsKey('category')) {
        _categoryFilter = args['category'] as String;
      }
      if (args.containsKey('zone')) {
        _zoneFilter = args['zone'] as TemperatureZone;
      }
    }
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      List<Product> products = productProvider.products;

      // Apply filters
      if (_categoryFilter != null) {
        products = products.where((p) => p.category == _categoryFilter).toList();
      }

      if (_zoneFilter != null) {
        products = products.where((p) => p.temperatureRequirement.zone == _zoneFilter).toList();
      }

      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        products = products.where((p) => 
          p.name.toLowerCase().contains(searchTerm) ||
          p.description.toLowerCase().contains(searchTerm) ||
          p.category.toLowerCase().contains(searchTerm)
        ).toList();
      }

      setState(() {
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Products';
    if (_categoryFilter != null) {
      title = _categoryFilter!;
    } else if (_zoneFilter != null) {
      title = '${_zoneFilter.toString().split('.').last} Zone Products';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(
                  Provider.of<ProductProvider>(context, listen: false).products,
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _filteredProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No products found${_categoryFilter != null ? ' in $_categoryFilter' : ''}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (ctx, index) {
                return CustomProductCard(
                  product: _filteredProducts[index],
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppConstants.productDetailRoute,
                      arguments: _filteredProducts[index],
                    );
                  },
                  onAddToCart: () {
                    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                    orderProvider.addToCart(_filteredProducts[index], 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart')),
                    );
                  },
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ProductSearchDelegate extends SearchDelegate<Product?> {
  final List<Product> products;

  ProductSearchDelegate(this.products);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final searchResults = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
             product.description.toLowerCase().contains(query.toLowerCase()) ||
             product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return searchResults.isEmpty
        ? Center(
            child: Text('No results found for "$query"'),
          )
        : ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final product = searchResults[index];
              return ListTile(
                leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: product.imageUrl != null
                      ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported),
                ),
                title: Text(product.name),
                subtitle: Text(product.category),
                trailing: Text('\$${product.price.toStringAsFixed(2)}'),
                onTap: () {
                  close(context, product);
                  Navigator.pushNamed(
                    context,
                    AppConstants.productDetailRoute,
                    arguments: product,
                  );
                },
              );
            },
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Search for products',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final searchResults = products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
             product.description.toLowerCase().contains(query.toLowerCase()) ||
             product.category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final product = searchResults[index];
        return ListTile(
          leading: SizedBox(
            width: 50,
            height: 50,
            child: product.imageUrl != null
                ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.image_not_supported),
          ),
          title: Text(product.name),
          subtitle: Text(product.category),
          trailing: Text('\$${product.price.toStringAsFixed(2)}'),
          onTap: () {
            close(context, product);
            Navigator.pushNamed(
              context,
              AppConstants.productDetailRoute,
              arguments: product,
            );
          },
        );
      },
    );
  }
} 