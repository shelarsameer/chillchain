import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../constants/app_constants.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/storage_provider.dart';
import '../../widgets/product_card.dart';
import '../../widgets/custom_product_card.dart';
import '../../widgets/drawer_menu.dart';
import '../../widgets/warning_banner.dart';
import '../../widgets/product_card_fixer.dart';
import 'storage_facilities_screen.dart';
import 'cold_storage_marketplace_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Product> _searchResults = [];
  final PageController _bannerController = PageController();
  int _currentBanner = 0;
  bool _isDarkMode = false;

  // Banner data for the image slider
  final List<Map<String, dynamic>> _banners = [
    {
      'title': 'Cold Storage Solutions',
      'subtitle': 'Best rates for perishable goods',
      'image': 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d',
      'color': Colors.blue.shade700
    },
    {
      'title': 'Fresh Products Marketplace',
      'subtitle': 'Buy directly from cold storage',
      'image': 'https://images.unsplash.com/photo-1595246007497-68986932fb03',
      'color': Colors.green.shade700
    },
    {
      'title': 'Temperature-Controlled Logistics',
      'subtitle': 'Track your products in real-time',
      'image': 'https://images.unsplash.com/photo-1604335398980-adadb8c2e0e3',
      'color': Colors.orange.shade700
    },
  ];

  @override
  void initState() {
    super.initState();
    // Start the banner auto-scroll
    Future.delayed(const Duration(seconds: 1), () {
      _startBannerTimer();
    });
  }

  void _startBannerTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        if (_currentBanner < _banners.length - 1) {
          _currentBanner++;
        } else {
          _currentBanner = 0;
        }
        
        if (_bannerController.hasClients) {
          _bannerController.animateToPage(
            _currentBanner,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeIn,
          );
        }
        _startBannerTimer();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
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
    final storageProvider = Provider.of<StorageProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      body: _isSearching && _searchResults.isNotEmpty
          ? _buildSearchResults()
          : RefreshIndicator(
              onRefresh: () => productProvider.initialize(),
              child: productProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : productProvider.error != null
                      ? _buildErrorView(productProvider)
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildBannerSlider(),
                                    _buildQuickActions(),
                                    _buildDashboardStats(orderProvider, storageProvider),
                                    _buildTemperatureZonesSection(),
                                    _buildCategoriesSection(),
                                    _buildRecommendedProductsSection(productProvider),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
      drawer: const DrawerMenu(),
      appBar: AppBar(
        title: _isSearching 
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Colors.black54),
                ),
                style: TextStyle(color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black),
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
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, AppConstants.cartRoute);
                },
              ),
              if (orderProvider.cartItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${orderProvider.cartItemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        elevation: 0,
      ),
    );
  }

  Widget _buildErrorView(ProductProvider productProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: ${productProvider.error}',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => productProvider.initialize(),
            child: const Text('Retry'),
          ),
        ],
      ),
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
        return CustomProductCard(
          product: _searchResults[index],
          onTap: () {
            Navigator.pushNamed(
              context,
              AppConstants.productDetailRoute,
              arguments: _searchResults[index],
            );
          },
          onAddToCart: () {
            final orderProvider = Provider.of<OrderProvider>(context, listen: false);
            orderProvider.addToCart(_searchResults[index], 1);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Added to cart')),
            );
          },
        );
      },
    );
  }

  Widget _buildBannerSlider() {
    final List<String> bannerImages = [
      'https://images.unsplash.com/photo-1534723452862-4c874018d66d',
      'https://images.unsplash.com/photo-1553546895-531931aa1aa8',
      'https://images.unsplash.com/photo-1580537659466-0a9bfa916a54',
    ];
    
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentBanner = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          banner['color'],
                          banner['color'].withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (rect) {
                      return const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [Colors.black, Colors.transparent],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.network(
                      bannerImages[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: banner['color'].withOpacity(0.3),
                          child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          banner['subtitle'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            shadows: [
                              Shadow(
                                blurRadius: 8.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (index == 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StorageFacilitiesScreen(),
                                ),
                              );
                            } else if (index == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ColdStorageMarketplaceScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: banner['color'],
                            backgroundColor: Colors.white,
                          ),
                          child: const Text('Learn More'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _banners.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentBanner == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final List<Map<String, dynamic>> actions = [
      {
        'icon': Icons.warehouse,
        'title': 'Book Storage',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StorageFacilitiesScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.shopping_bag,
        'title': 'Marketplace',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ColdStorageMarketplaceScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.history,
        'title': 'Orders',
        'onTap': () {
          Navigator.pushNamed(context, AppConstants.orderHistoryRoute);
        },
      },
      {
        'icon': Icons.track_changes,
        'title': 'Track',
        'onTap': () {
          Navigator.pushNamed(context, AppConstants.trackOrderRoute);
        },
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((action) {
          return InkWell(
            onTap: action['onTap'],
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    action['icon'],
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action['title'],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDashboardStats(OrderProvider orderProvider, StorageProvider storageProvider) {
    final stats = [
      {
        'title': 'Orders',
        'value': orderProvider.orders.length.toString(),
        'icon': Icons.shopping_bag_outlined,
      },
      {
        'title': 'Storage',
        'value': storageProvider.userBookings.length.toString(),
        'icon': Icons.warehouse_outlined,
      },
      {
        'title': 'Saved',
        'value': '0',
        'icon': Icons.favorite_outline,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: stats.map((stat) {
              return Expanded(
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          stat['icon'] as IconData,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stat['value'] as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stat['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureZonesSection() {
    final zones = [
      {
        'name': 'FROZEN',
        'icon': Icons.ac_unit,
        'color': Colors.blue.shade700,
        'zone': TemperatureZone.frozen,
        'description': '-18°C and below',
      },
      {
        'name': 'CHILLED',
        'icon': Icons.kitchen,
        'color': Colors.blue.shade300,
        'zone': TemperatureZone.chilled,
        'description': '0°C to 5°C',
      },
      {
        'name': 'COOL',
        'icon': Icons.thermostat,
        'color': Colors.green.shade300,
        'zone': TemperatureZone.cool,
        'description': '6°C to 15°C',
      },
      {
        'name': 'AMBIENT',
        'icon': Icons.wb_sunny,
        'color': Colors.amber.shade700,
        'zone': TemperatureZone.ambient,
        'description': '16°C to 25°C',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Temperature Zones', null),
          const SizedBox(height: 12),
          Row(
            children: zones.map((zone) {
              return Expanded(
                child: InkWell(
                  onTap: () {
                    // Navigate to zone products
                    Navigator.pushNamed(
                      context, 
                      AppConstants.productListRoute,
                      arguments: {'zone': zone['zone']},
                    );
                  },
                  child: Card(
                    color: zone['color'] as Color,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            zone['icon'] as IconData,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            zone['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            zone['description'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
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
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionHeader('Categories', () {
              Navigator.pushNamed(context, AppConstants.productListRoute);
            }),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (ctx, index) {
              final category = categories[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    // Navigate to category products
                    Navigator.pushNamed(
                      context,
                      AppConstants.productListRoute,
                      arguments: {'category': category['name']},
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          size: 30,
                          color: Theme.of(context).primaryColor,
                        ),
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
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildSectionHeader('Recommended For You', () {
              Navigator.pushNamed(context, AppConstants.productListRoute);
            }),
          ),
          const SizedBox(height: 12),
          recommendedProducts.isEmpty
              ? _buildEmptyState('No recommended products available')
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: math.min(9, recommendedProducts.length), // Show up to 9 items
                    itemBuilder: (ctx, index) {
                      return SizedBox(
                        height: 160, // Smaller fixed height
                        child: CustomProductCard(
                          product: recommendedProducts[index],
                          compact: true,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppConstants.productDetailRoute,
                              arguments: recommendedProducts[index],
                            );
                          },
                          onAddToCart: () {
                            final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                            orderProvider.addToCart(recommendedProducts[index], 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart')),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('See All'),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
} 