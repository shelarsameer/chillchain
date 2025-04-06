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
      stock: 25,
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
      stock: 12,
    ),
    Product(
      id: '3',
      name: 'Vanilla Ice Cream',
      description: 'Rich and creamy vanilla ice cream',
      price: 5.99,
      imageUrl: 'https://images.unsplash.com/photo-1570197788417-0e82375c9371',
      category: 'Ice Cream',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: -25.0,
        maxTemperature: -18.0,
        zone: TemperatureZone.frozen,
      ),
      weight: 0.5,
      expiryDate: DateTime.now().add(const Duration(days: 90)),
      vendorId: 'vendor2',
      stock: 45,
    ),
    Product(
      id: '4',
      name: 'Fresh Atlantic Salmon',
      description: 'Wild-caught Atlantic salmon, perfect for sushi',
      price: 18.99,
      imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2',
      category: 'Seafood',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: -1.0,
        maxTemperature: 1.0,
        zone: TemperatureZone.chilled,
      ),
      weight: 0.3,
      expiryDate: DateTime.now().add(const Duration(days: 3)),
      vendorId: 'vendor3',
      stock: 18,
    ),
    Product(
      id: '5',
      name: 'Organic Apples',
      description: 'Fresh organic apples from local orchards',
      price: 2.49,
      imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6',
      category: 'Fruits',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: 4.0,
        maxTemperature: 10.0,
        zone: TemperatureZone.cool,
      ),
      weight: 1.0,
      expiryDate: DateTime.now().add(const Duration(days: 14)),
      vendorId: 'vendor2',
      stock: 30,
    ),
    Product(
      id: '6',
      name: 'Frozen Pizza',
      description: 'Stone-baked pepperoni pizza, ready to cook',
      price: 7.99,
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591',
      category: 'Frozen Foods',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: -22.0,
        maxTemperature: -18.0,
        zone: TemperatureZone.frozen,
      ),
      weight: 0.4,
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      vendorId: 'vendor3',
      stock: 24,
    ),
    Product(
      id: '7',
      name: 'Fresh Broccoli',
      description: 'Farm-fresh broccoli, high in vitamins and nutrients',
      price: 1.99,
      imageUrl: 'https://images.unsplash.com/photo-1459411552884-841db9b3cc2a',
      category: 'Vegetables',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: 0.0,
        maxTemperature: 4.0,
        zone: TemperatureZone.chilled,
      ),
      weight: 0.3,
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      vendorId: 'vendor2',
      stock: 15,
    ),
    Product(
      id: '8',
      name: 'Frozen Berries Mix',
      description: 'Mix of strawberries, blueberries and raspberries',
      price: 4.99,
      imageUrl: 'https://images.unsplash.com/photo-1563746924237-f4471935addd',
      category: 'Frozen Foods',
      temperatureRequirement: TemperatureRequirement(
        minTemperature: -23.0,
        maxTemperature: -18.0,
        zone: TemperatureZone.frozen,
      ),
      weight: 0.4,
      expiryDate: DateTime.now().add(const Duration(days: 365)),
      vendorId: 'vendor1',
      stock: 35,
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
} 