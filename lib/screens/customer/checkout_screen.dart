import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _noteController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;
  String _paymentMethod = 'Credit Card';
  
  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final cartItems = orderProvider.cartItems;
    final cartSubtotal = orderProvider.cartSubtotal;
    final deliveryFee = 4.99;
    final tax = cartSubtotal * 0.10; // 10% tax rate
    final total = cartSubtotal + deliveryFee + tax;
    
    if (cartItems.isEmpty) {
      // Redirect to cart if empty
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty')),
        );
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary Card
                    _buildSummaryCard(cartItems.length, total),
                    const SizedBox(height: 24),
                    
                    // Delivery Details Section
                    const Text(
                      'Delivery Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Address Field
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address',
                        hintText: 'Enter your full delivery address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your delivery address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'Enter your phone number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Payment Method Section
                    const Text(
                      'Payment Method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Payment Method Selector
                    _buildPaymentMethodSelector(),
                    const SizedBox(height: 24),
                    
                    // Additional Notes
                    const Text(
                      'Additional Notes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Notes Field
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Order Notes (Optional)',
                        hintText: 'Any special instructions for delivery',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note_outlined),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    
                    // Order Total Summary
                    _buildOrderTotalSummary(
                      cartSubtotal: cartSubtotal,
                      deliveryFee: deliveryFee,
                      tax: tax,
                      total: total,
                    ),
                    const SizedBox(height: 24),
                    
                    // Error Display
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(AppConstants.smallPadding),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _placeOrder(
                          context,
                          authProvider,
                          orderProvider,
                          total,
                          deliveryFee,
                          tax,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Place Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildSummaryCard(int itemCount, double total) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Row(
          children: [
            const Icon(
              Icons.shopping_cart_checkout,
              size: 40,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$itemCount ${itemCount == 1 ? 'item' : 'items'} • \$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        _buildPaymentOption(
          'Credit Card',
          Icons.credit_card,
          _paymentMethod == 'Credit Card',
          () {
            setState(() {
              _paymentMethod = 'Credit Card';
            });
          },
        ),
        const Divider(),
        _buildPaymentOption(
          'PayPal',
          Icons.payment,
          _paymentMethod == 'PayPal',
          () {
            setState(() {
              _paymentMethod = 'PayPal';
            });
          },
        ),
        const Divider(),
        _buildPaymentOption(
          'Cash on Delivery',
          Icons.money,
          _paymentMethod == 'Cash on Delivery',
          () {
            setState(() {
              _paymentMethod = 'Cash on Delivery';
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildPaymentOption(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppConstants.primaryColor
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Radio<String>(
              value: title,
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
              activeColor: AppConstants.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderTotalSummary({
    required double cartSubtotal,
    required double deliveryFee,
    required double tax,
    required double total,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Column(
        children: [
          _buildSummaryItem('Subtotal', '\$${cartSubtotal.toStringAsFixed(2)}'),
          _buildSummaryItem('Delivery Fee', '\$${deliveryFee.toStringAsFixed(2)}'),
          _buildSummaryItem('Tax (10%)', '\$${tax.toStringAsFixed(2)}'),
          const Divider(),
          _buildSummaryItem(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _placeOrder(
    BuildContext context,
    AuthProvider authProvider,
    OrderProvider orderProvider,
    double total,
    double deliveryFee,
    double tax,
  ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Close the keyboard
    FocusScope.of(context).unfocus();
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final userId = authProvider.currentUser?.id ?? 'demo_user';
      
      // In a real app, you'd have the vendor ID from the products
      // For demo purposes, we'll use a fixed vendor ID
      const vendorId = 'vendor1';
      
      final order = await orderProvider.createOrder(
        userId: userId,
        vendorId: vendorId,
        items: orderProvider.cartItems,
        subtotal: orderProvider.cartSubtotal,
        deliveryFee: deliveryFee,
        tax: tax,
        total: total,
        deliveryAddress: _addressController.text,
        notes: _noteController.text.isNotEmpty ? _noteController.text : null,
      );
      
      // Clear cart after successful order
      if (order != null) {
        orderProvider.clearCart();
        
        // Navigate to order confirmation page
        _showOrderConfirmation(context, order);
      } else {
        // Handle error
        setState(() {
          _error = 'Failed to place order. Please try again.';
        });
      }
      
    } catch (e) {
      setState(() {
        _error = 'An error occurred: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showOrderConfirmation(BuildContext context, Order order) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(order: order),
      ),
    );
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;
  
  const OrderConfirmationScreen({
    Key? key,
    required this.order,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppConstants.successColor,
                size: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your order ID: ${order.id}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Total amount: \$${order.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Thank you for your order! You will receive a confirmation email shortly.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate back to home screen
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppConstants.homeRoute,
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigate to order tracking
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppConstants.trackOrderRoute,
                    (route) => false,
                  );
                },
                child: const Text('Track My Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 