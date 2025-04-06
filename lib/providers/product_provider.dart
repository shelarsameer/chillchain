import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../services/product_service.dart';
import 'package:flutter/widgets.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();
  
  // Product lists
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _recommendedProducts = [];
  
  // Cart items
  List<OrderItem> _cartItems = [];
  
  // Loading and error states
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get recommendedProducts => _recommendedProducts;
  List<OrderItem> get cartItems => _cartItems;
  int get cartItemCount => _cartItems.length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  double get cartSubtotal {
    if (_cartItems.isEmpty) return 0.0;
    return _cartItems.fold(0.0, (total, item) => total + item.subtotal);
  }
  
  // Initialize products
  Future<void> initialize() async {
    print("ProductProvider: Initializing");
    try {
      _isLoading = true; // Set directly, don't call _setLoading during init
      
      // Fetch data without triggering notifications
      await _fetchProductsWithoutNotify();
      await _fetchFeaturedProductsWithoutNotify();
      await _fetchRecommendedProductsWithoutNotify();
      
      _isLoading = false; // Set directly, don't call _setLoading during init
      print("ProductProvider: Initialization complete");
      
      // Notify once at the end of initialization using the safe pattern
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            notifyListeners();
          }
        });
      }
    } catch (e) {
      print("ProductProvider: Initialization error: $e");
      _error = e.toString(); // Set directly, don't call _setError during init
      _isLoading = false; // Set directly, don't call _setLoading during init
      
      // Notify once at the end of initialization using the safe pattern
      if (WidgetsBinding.instance != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            notifyListeners();
          }
        });
      }
    }
  }
  
  // Private methods that don't notify listeners
  Future<void> _fetchProductsWithoutNotify() async {
    try {
      print("ProductProvider: Fetching products without notification");
      final products = await _productService.getProducts();
      _products = products;
    } catch (e) {
      print("ProductProvider: Error fetching products: $e");
      throw e;
    }
  }
  
  Future<void> _fetchFeaturedProductsWithoutNotify() async {
    try {
      print("ProductProvider: Fetching featured products without notification");
      final products = await _productService.getRandomProducts(8);
      _featuredProducts = products;
    } catch (e) {
      print("ProductProvider: Error fetching featured products: $e");
      // Don't throw, just continue
    }
  }
  
  Future<void> _fetchRecommendedProductsWithoutNotify() async {
    try {
      print("ProductProvider: Fetching recommended products without notification");
      final products = await _productService.getRandomProducts(6);
      _recommendedProducts = products;
    } catch (e) {
      print("ProductProvider: Error fetching recommended products: $e");
      // Don't throw, just continue
    }
  }
  
  // Fetch products by category
  Future<List<Product>> fetchProductsByCategory(String category) async {
    _setLoading(true);
    _clearError();
    
    try {
      final products = await _productService.getProductsByCategory(category);
      _setLoading(false);
      return products;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }
  
  // Fetch products by temperature zone
  Future<List<Product>> fetchProductsByTemperatureZone(TemperatureZone zone) async {
    _setLoading(true);
    _clearError();
    
    try {
      final products = await _productService.getProductsByTemperatureZone(zone);
      _setLoading(false);
      return products;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return [];
    }
  }
  
  // Get product by ID
  Future<Product?> getProductById(String id) async {
    // First check if it's already in our lists
    Product? product = _findProductInLists(id);
    if (product != null) return product;
    
    _setLoading(true);
    _clearError();
    
    try {
      product = await _productService.getProductById(id);
      _setLoading(false);
      return product;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }
  
  // Find a product in the existing lists
  Product? _findProductInLists(String id) {
    // Check in main products list
    final productIndex = _products.indexWhere((p) => p.id == id);
    if (productIndex != -1) return _products[productIndex];
    
    // Check in featured products list
    final featuredIndex = _featuredProducts.indexWhere((p) => p.id == id);
    if (featuredIndex != -1) return _featuredProducts[featuredIndex];
    
    // Check in recommended products list
    final recommendedIndex = _recommendedProducts.indexWhere((p) => p.id == id);
    if (recommendedIndex != -1) return _recommendedProducts[recommendedIndex];
    
    return null;
  }
  
  // Cart operations
  
  // Add to cart
  void addToCart(Product product, int quantity) {
    // Check if the product is already in the cart
    final existingIndex = _cartItems.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex != -1) {
      // Update quantity if the product is already in the cart
      final existingItem = _cartItems[existingIndex];
      final updatedItem = OrderItem(
        productId: existingItem.productId,
        quantity: existingItem.quantity + quantity,
        price: existingItem.price,
        temperatureRequirement: existingItem.temperatureRequirement,
      );
      
      _cartItems[existingIndex] = updatedItem;
    } else {
      // Add new item to cart
      _cartItems.add(
        OrderItem(
          productId: product.id,
          quantity: quantity,
          price: product.price,
          temperatureRequirement: product.temperatureRequirement,
        ),
      );
    }
    
    notifyListeners();
  }
  
  // Update cart item quantity
  void updateCartItemQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.productId == productId);
    
    if (index != -1) {
      if (quantity <= 0) {
        // Remove the item if quantity is 0 or less
        _cartItems.removeAt(index);
      } else {
        // Update the quantity
        final item = _cartItems[index];
        final updatedItem = OrderItem(
          productId: item.productId,
          quantity: quantity,
          price: item.price,
          temperatureRequirement: item.temperatureRequirement,
        );
        
        _cartItems[index] = updatedItem;
      }
      
      notifyListeners();
    }
  }
  
  // Remove item from cart
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }
  
  // Clear cart
  void clearCart() {
    _cartItems = [];
    notifyListeners();
  }
  
  // Search products
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    
    // Filter products based on the query
    return _products.where((product) => 
      product.name.toLowerCase().contains(query.toLowerCase()) ||
      product.description.toLowerCase().contains(query.toLowerCase()) ||
      product.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
  
  // Helper methods
  void _setLoading(bool value) {
    if (_isLoading == value) return; // Avoid unnecessary updates
    
    _isLoading = value;
    
    // Use addPostFrameCallback to ensure we're not notifying during build
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          notifyListeners();
        }
      });
    }
  }
  
  void _clearError() {
    if (_error == null) return; // Avoid unnecessary updates
    
    _error = null;
    
    // Use addPostFrameCallback to ensure we're not notifying during build
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          notifyListeners();
        }
      });
    }
  }
  
  void _setError(String error) {
    if (_error == error) return; // Avoid unnecessary updates
    
    _error = error;
    
    // Use addPostFrameCallback to ensure we're not notifying during build
    if (WidgetsBinding.instance != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          notifyListeners();
        }
      });
    }
  }

  // Add a property to track if the provider is mounted
  bool _mounted = true;
  bool get mounted => _mounted;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  // Fetch all products
  Future<void> fetchProducts() async {
    _setLoading(true);
    _clearError();
    
    try {
      final products = await _productService.getProducts();
      _products = products;
      _setLoading(false);
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  // Fetch featured products
  Future<void> fetchFeaturedProducts() async {
    try {
      final products = await _productService.getRandomProducts(8);
      _featuredProducts = products;
      notifyListeners();
    } catch (e) {
      print('Error fetching featured products: $e');
    }
  }
  
  // Fetch recommended products
  Future<void> fetchRecommendedProducts() async {
    try {
      final products = await _productService.getRandomProducts(6);
      _recommendedProducts = products;
      notifyListeners();
    } catch (e) {
      print('Error fetching recommended products: $e');
    }
  }

  // Find a product by its ID
  Product? findProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      // If the product is not found, return null
      return null;
    }
  }

  // Add new product
  Future<void> addProduct(Product product) async {
    _setLoading(true);
    _clearError();
    
    try {
      final newProduct = await _productService.addProduct(product);
      
      // Add to the products list
      _products.add(newProduct);
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      throw e; // Re-throw to let the UI handle it
    }
  }
  
  // Update existing product
  Future<void> updateProduct(Product product) async {
    _setLoading(true);
    _clearError();
    
    try {
      final updatedProduct = await _productService.updateProduct(product);
      
      // Update in the products list
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index >= 0) {
        _products[index] = updatedProduct;
      }
      
      // Also update in other lists if present
      final featuredIndex = _featuredProducts.indexWhere((p) => p.id == product.id);
      if (featuredIndex >= 0) {
        _featuredProducts[featuredIndex] = updatedProduct;
      }
      
      final recommendedIndex = _recommendedProducts.indexWhere((p) => p.id == product.id);
      if (recommendedIndex >= 0) {
        _recommendedProducts[recommendedIndex] = updatedProduct;
      }
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      throw e; // Re-throw to let the UI handle it
    }
  }
  
  // Delete product
  Future<void> deleteProduct(String productId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _productService.deleteProduct(productId);
      
      // Remove from all lists
      _products.removeWhere((p) => p.id == productId);
      _featuredProducts.removeWhere((p) => p.id == productId);
      _recommendedProducts.removeWhere((p) => p.id == productId);
      
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      throw e; // Re-throw to let the UI handle it
    }
  }
  
  // Fetch products for a specific vendor
  Future<List<Product>> fetchVendorProducts(String vendorId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final products = await _productService.getProductsByVendor(vendorId);
      
      // If these are not already in our main list, add them
      for (final product in products) {
        final existingIndex = _products.indexWhere((p) => p.id == product.id);
        if (existingIndex < 0) {
          _products.add(product);
        }
      }
      
      _setLoading(false);
      notifyListeners();
      return products;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return []; // Return empty list on error
    }
  }
} 