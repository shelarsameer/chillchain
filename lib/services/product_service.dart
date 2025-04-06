import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/product.dart';

class ProductService {
  static const String _baseUrl = '${AppConstants.apiBaseUrl}/products';
  static const String _cacheKey = 'cached_products';
  static const Duration _cacheDuration = Duration(hours: 1);
  
  // For demo/MVP purpose
  static final List<Product> _demoProducts = [
    Product(
      id: '1',
      name: 'Fresh Milk',
      description: 'Organic fresh milk from local farms',
      price: 3.99,
      imageUrl: 'https://images.unsplash.com/photo-1563636619-e9143da7973b',
      category: 'Dairy',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: 0.0,
        maxTemperature: 4.0,
        zone: TemperatureZone.chilled,
      ),
      weight: 1.0,
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      vendorId: 'vendor1',
      stockQuantity: 25,
    ),
    Product(
      id: '2',
      name: 'Premium Beef Steak',
      description: 'High-quality beef steak, perfect for grilling',
      price: 15.99,
      imageUrl: 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f',
      category: 'Meat',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: -2.0,
        maxTemperature: 2.0,
        zone: TemperatureZone.chilled,
      ),
      weight: 0.5,
      expiryDate: DateTime.now().add(const Duration(days: 5)),
      vendorId: 'vendor1',
      stockQuantity: 12,
    ),
    Product(
      id: '3',
      name: 'Frozen Pizza',
      description: 'Stone-baked pepperoni pizza, ready to cook',
      price: 7.99,
      imageUrl: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38',
      category: 'Ready Meals',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: -20.0,
        maxTemperature: -18.0,
        zone: TemperatureZone.frozen,
      ),
      weight: 0.4,
      expiryDate: DateTime.now().add(const Duration(days: 90)),
      vendorId: 'vendor2',
      stockQuantity: 40,
    ),
    Product(
      id: '4',
      name: 'Vanilla Ice Cream',
      description: 'Rich and creamy vanilla ice cream',
      price: 5.99,
      imageUrl: 'https://images.unsplash.com/photo-1566454419290-57a0589c9b31',
      category: 'Desserts',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: -23.0,
        maxTemperature: -18.0,
        zone: TemperatureZone.frozen,
      ),
      weight: 0.5,
      expiryDate: DateTime.now().add(const Duration(days: 120)),
      vendorId: 'vendor3',
      stockQuantity: 30,
    ),
    Product(
      id: '5',
      name: 'Fresh Broccoli',
      description: 'Farm-fresh broccoli, high in vitamins and nutrients',
      price: 1.99,
      imageUrl: 'https://images.unsplash.com/photo-1459411621453-7b03977f4bfc',
      category: 'Vegetables',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: 0.0,
        maxTemperature: 4.0,
        zone: TemperatureZone.chilled,
      ),
      weight: 0.3,
      expiryDate: DateTime.now().add(const Duration(days: 10)),
      vendorId: 'vendor2',
      stockQuantity: 45,
    ),
    Product(
      id: '6',
      name: 'Organic Apples',
      description: 'Fresh organic apples from local orchards',
      price: 2.49,
      imageUrl: 'https://images.unsplash.com/photo-1567306226416-28f0efdc88ce',
      category: 'Fruits',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: 2.0,
        maxTemperature: 8.0,
        zone: TemperatureZone.cool,
      ),
      weight: 1.0,
      expiryDate: DateTime.now().add(const Duration(days: 14)),
      vendorId: 'vendor1',
      stockQuantity: 60,
    ),
    Product(
      id: '7',
      name: 'Frozen Berries Mix',
      description: 'Mix of strawberries, blueberries and raspberries',
      price: 4.99,
      imageUrl: 'https://images.unsplash.com/photo-1498557850523-fd3d118b962e',
      category: 'Fruits',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: -20.0,
        maxTemperature: -18.0,
        zone: TemperatureZone.frozen,
      ),
      weight: 0.5,
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      vendorId: 'vendor3',
      stockQuantity: 35,
    ),
    Product(
      id: '8',
      name: 'Fresh Salmon Fillet',
      description: 'Premium Atlantic salmon, rich in omega-3',
      price: 9.99,
      imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2',
      category: 'Seafood',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: -2.0,
        maxTemperature: 2.0,
        zone: TemperatureZone.chilled,
      ),
      weight: 0.3,
      expiryDate: DateTime.now().add(const Duration(days: 3)),
      vendorId: 'vendor2',
      stockQuantity: 18,
    ),
    Product(
      id: '9',
      name: 'Organic Yogurt',
      description: 'Probiotic-rich organic yogurt, no added sugar',
      price: 3.29,
      imageUrl: 'https://images.unsplash.com/photo-1615478503562-ec2d8aa0e24e',
      category: 'Dairy',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: 0.0,
        maxTemperature: 4.0,
        zone: TemperatureZone.chilled,
      ),
      weight: 0.5,
      expiryDate: DateTime.now().add(const Duration(days: 14)),
      vendorId: 'vendor1',
      stockQuantity: 28,
    ),
    Product(
      id: '10',
      name: 'Frozen Vegetables',
      description: 'Mixed vegetables, flash-frozen for freshness',
      price: 3.49,
      imageUrl: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf',
      category: 'Vegetables',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: -20.0,
        maxTemperature: -18.0,
        zone: TemperatureZone.frozen,
      ),
      weight: 0.75,
      expiryDate: DateTime.now().add(const Duration(days: 150)),
      vendorId: 'vendor2',
      stockQuantity: 50,
    ),
    Product(
      id: '11',
      name: 'Fresh Orange Juice',
      description: 'Freshly squeezed orange juice, no preservatives',
      price: 4.50,
      imageUrl: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba',
      category: 'Beverages',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: 0.0,
        maxTemperature: 4.0,
        zone: TemperatureZone.chilled,
      ),
      weight: 1.0,
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      vendorId: 'vendor3',
      stockQuantity: 20,
    ),
    Product(
      id: '12',
      name: 'Artisan Cheese',
      description: 'Handcrafted cheese from local dairy farms',
      price: 6.99,
      imageUrl: 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d',
      category: 'Dairy',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: 2.0,
        maxTemperature: 6.0,
        zone: TemperatureZone.chilled,
      ),
      weight: 0.25,
      expiryDate: DateTime.now().add(const Duration(days: 21)),
      vendorId: 'vendor1',
      stockQuantity: 15,
    ),
  ];
  
  // Fetch all products
  Future<List<Product>> getProducts() async {
    try {
      if (AppConstants.isDemoMode) {
        // Return demo products for MVP
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
        return _demoProducts;
      }
      
      // First try to get from cache
      final cachedProducts = await _getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        return cachedProducts;
      }
      
      // If no cache, fetch from API
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final products = data.map((json) => Product.fromMap(json)).toList();
        
        // Cache the products
        await _cacheProducts(products);
        
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // If there's an error, try to return cached products as a fallback
      final cachedProducts = await _getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        return cachedProducts;
      }
      rethrow;
    }
  }
  
  // Get a single product by ID
  Future<Product> getProductById(String id) async {
    try {
      if (AppConstants.isDemoMode) {
        // Return demo product for MVP
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        final product = _demoProducts.firstWhere(
          (p) => p.id == id,
          orElse: () => throw Exception('Product not found'),
        );
        return product;
      }
      
      // Try to get from cache first
      final cachedProducts = await _getCachedProducts();
      final cachedProduct = cachedProducts.where((p) => p.id == id).toList();
      if (cachedProduct.isNotEmpty) {
        return cachedProduct.first;
      }
      
      // If not in cache, fetch from API
      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromMap(data);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Search products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      if (AppConstants.isDemoMode) {
        // Return filtered demo products for MVP
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        return _demoProducts.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/category/$category'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load products by category: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Search products by temperature zone
  Future<List<Product>> getProductsByTemperatureZone(TemperatureZone zone) async {
    try {
      if (AppConstants.isDemoMode) {
        // Return filtered demo products for MVP
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        return _demoProducts.where((p) => p.temperatureRequirement.zone == zone).toList();
      }
      
      final zoneName = zone.toString().split('.').last;
      final response = await http.get(
        Uri.parse('$_baseUrl/temperature-zone/$zoneName'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load products by temperature zone: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Search products by vendor
  Future<List<Product>> getProductsByVendor(String vendorId) async {
    try {
      if (AppConstants.isDemoMode) {
        // Return filtered demo products for MVP
        await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
        return _demoProducts.where((p) => p.vendorId == vendorId).toList();
      }
      
      final response = await http.get(
        Uri.parse('$_baseUrl/vendor/$vendorId'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load products by vendor: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // For demo purposes - get random products
  Future<List<Product>> getRandomProducts(int count) async {
    if (AppConstants.isDemoMode) {
      // Return random demo products for MVP
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
      
      final random = Random();
      final shuffledProducts = List<Product>.from(_demoProducts)..shuffle(random);
      
      return shuffledProducts.take(min(count, shuffledProducts.length)).toList();
    }
    
    final allProducts = await getProducts();
    final random = Random();
    final shuffledProducts = List<Product>.from(allProducts)..shuffle(random);
    
    return shuffledProducts.take(min(count, shuffledProducts.length)).toList();
  }
  
  // Save products to cache
  Future<void> _cacheProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = products.map((p) => json.encode(p.toMap())).toList();
      await prefs.setStringList(_cacheKey, productsJson);
      
      // Save cache timestamp
      await prefs.setInt('${_cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Silently fail on cache errors
      print('Failed to cache products: $e');
    }
  }
  
  // Get cached products
  Future<List<Product>> _getCachedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedList = prefs.getStringList(_cacheKey);
      final cacheTimestamp = prefs.getInt('${_cacheKey}_timestamp') ?? 0;
      
      // Check if cache is expired
      final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTimestamp;
      if (cacheAge > _cacheDuration.inMilliseconds) {
        return [];
      }
      
      if (cachedList != null && cachedList.isNotEmpty) {
        return cachedList
            .map((item) => Product.fromMap(json.decode(item)))
            .toList();
      }
      
      return [];
    } catch (e) {
      // Return empty list on cache errors
      return [];
    }
  }
  
  // Get API request headers
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey) ?? '';
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Add a new product
  Future<Product> addProduct(Product product) async {
    try {
      if (AppConstants.isDemoMode) {
        // Simulate adding a product in demo mode
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
        
        // Create a copy with a new ID
        final newId = (int.parse(_demoProducts.map((p) => p.id).toList().reduce(
              (a, b) => int.parse(a) > int.parse(b) ? a : b,
            )) + 1).toString();
        
        final newProduct = Product(
          id: newId,
          name: product.name,
          description: product.description,
          price: product.price,
          category: product.category,
          temperatureRequirement: product.temperatureRequirement,
          weight: product.weight,
          expiryDate: product.expiryDate,
          vendorId: product.vendorId,
          stockQuantity: product.stockQuantity,
          imageUrl: product.imageUrl,
          rating: 0.0, // New product starts with no rating
          reviews: [],
        );
        
        // Add to demo products
        _demoProducts.add(newProduct);
        
        return newProduct;
      }
      
      // If not in demo mode, send to API
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: await _getHeaders(),
        body: json.encode(product.toMap()),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final newProduct = Product.fromMap(data);
        
        // Update cache
        final cachedProducts = await _getCachedProducts();
        cachedProducts.add(newProduct);
        await _cacheProducts(cachedProducts);
        
        return newProduct;
      } else {
        throw Exception('Failed to add product: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Update an existing product
  Future<Product> updateProduct(Product product) async {
    try {
      if (AppConstants.isDemoMode) {
        // Simulate updating a product in demo mode
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
        
        // Find and update the product
        final index = _demoProducts.indexWhere((p) => p.id == product.id);
        if (index >= 0) {
          // Preserve the reviews and rating
          final existingProduct = _demoProducts[index];
          final updatedProduct = Product(
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            category: product.category,
            temperatureRequirement: product.temperatureRequirement,
            weight: product.weight,
            expiryDate: product.expiryDate,
            vendorId: product.vendorId,
            stockQuantity: product.stockQuantity,
            imageUrl: product.imageUrl,
            rating: existingProduct.rating,
            reviews: existingProduct.reviews,
          );
          
          _demoProducts[index] = updatedProduct;
          return updatedProduct;
        } else {
          throw Exception('Product not found');
        }
      }
      
      // If not in demo mode, send to API
      final response = await http.put(
        Uri.parse('$_baseUrl/${product.id}'),
        headers: await _getHeaders(),
        body: json.encode(product.toMap()),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedProduct = Product.fromMap(data);
        
        // Update cache
        final cachedProducts = await _getCachedProducts();
        final index = cachedProducts.indexWhere((p) => p.id == product.id);
        if (index >= 0) {
          cachedProducts[index] = updatedProduct;
          await _cacheProducts(cachedProducts);
        }
        
        return updatedProduct;
      } else {
        throw Exception('Failed to update product: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      if (AppConstants.isDemoMode) {
        // Simulate deleting a product in demo mode
        await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
        
        // Remove the product
        _demoProducts.removeWhere((p) => p.id == productId);
        return;
      }
      
      // If not in demo mode, send to API
      final response = await http.delete(
        Uri.parse('$_baseUrl/$productId'),
        headers: await _getHeaders(),
      ).timeout(Duration(seconds: AppConstants.apiTimeoutSeconds));
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Update cache
        final cachedProducts = await _getCachedProducts();
        cachedProducts.removeWhere((p) => p.id == productId);
        await _cacheProducts(cachedProducts);
      } else {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
} 