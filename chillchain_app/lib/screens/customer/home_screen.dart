import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/product_card.dart';
import 'storage_facilities_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Product> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final results = await productProvider.searchProducts(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final user = authProvider.currentUser;

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
                onChanged: _performSearch,
              )
            : Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _searchResults = [];
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to cart screen
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Guest'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'G',
                  style: TextStyle(fontSize: 24.0, color: AppConstants.primaryColor),
                ),
              ),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categories'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to categories screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Order History'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to order history screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text('Track Orders'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to order tracking screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to profile screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.signOut();
                // Navigation will be handled by a listener
              },
            ),
          ],
        ),
      ),
      body: _isSearching && _searchResults.isNotEmpty
          ? _buildSearchResults()
          : _buildHomeContent(),
    );
  }

  Widget _buildSearchResults() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (ctx, index) {
        return ProductCard(product: _searchResults[index]);
      },
    );
  }

  Widget _buildHomeContent() {
    return Consumer<ProductProvider>(
      builder: (ctx, productProvider, _) {
        if (productProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (productProvider.error != null) {
          return Center(
            child: Text(
              'Error: ${productProvider.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => productProvider.initialize(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTemperatureZonesSection(),
                _buildFeaturedProductsSection(productProvider),
                _buildCategoriesSection(),
                _buildRecommendedProductsSection(productProvider),
                _buildDashboardCard(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemperatureZonesSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temperature Zones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: TemperatureZone.values.map((zone) {
                Color zoneColor;
                IconData zoneIcon;
                
                switch (zone) {
                  case TemperatureZone.frozen:
                    zoneColor = Colors.blue.shade700;
                    zoneIcon = Icons.ac_unit;
                    break;
                  case TemperatureZone.chilled:
                    zoneColor = Colors.blue.shade300;
                    zoneIcon = Icons.kitchen;
                    break;
                  case TemperatureZone.cool:
                    zoneColor = Colors.green.shade300;
                    zoneIcon = Icons.thermostat;
                    break;
                  case TemperatureZone.ambient:
                    zoneColor = Colors.amber.shade700;
                    zoneIcon = Icons.wb_sunny;
                    break;
                }
                
                return Card(
                  color: zoneColor,
                  margin: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      // Navigate to zone products
                    },
                    child: SizedBox(
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            zoneIcon,
                            color: Colors.white,
                            size: 36,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            zone.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductsSection(ProductProvider productProvider) {
    final featuredProducts = productProvider.featuredProducts;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all products
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          featuredProducts.isEmpty
              ? const Center(
                  child: Text('No featured products available'),
                )
              : SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: featuredProducts.length,
                    itemBuilder: (ctx, index) {
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 12),
                        child: ProductCard(product: featuredProducts[index]),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    // Demo categories
    final categories = [
      {'name': 'Dairy', 'icon': Icons.egg_alt},
      {'name': 'Meat', 'icon': Icons.restaurant},
      {'name': 'Fruits', 'icon': Icons.apple},
      {'name': 'Vegetables', 'icon': Icons.eco},
      {'name': 'Seafood', 'icon': Icons.water},
      {'name': 'Beverages', 'icon': Icons.local_drink},
    ];
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: categories.length,
            itemBuilder: (ctx, index) {
              final category = categories[index];
              return Card(
                elevation: 2,
                child: InkWell(
                  onTap: () {
                    // Navigate to category products
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        size: 36,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedProductsSection(ProductProvider productProvider) {
    final recommendedProducts = productProvider.recommendedProducts;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recommended For You',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all products
                },
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          recommendedProducts.isEmpty
              ? const Center(
                  child: Text('No recommended products available'),
                )
              : GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: recommendedProducts.length,
                  itemBuilder: (ctx, index) {
                    return ProductCard(product: recommendedProducts[index]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // ... existing dashboard widgets ...
          
          // Add storage facilities button
          ListTile(
            leading: const Icon(Icons.warehouse, color: AppConstants.primaryColor),
            title: const Text('Cold Storage Facilities'),
            subtitle: const Text('Find and book cold storage for your products'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StorageFacilitiesScreen(),
                ),
              );
            },
          ),
          
          // ... other dashboard widgets ...
        ],
      ),
    );
  }
} 