import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants/app_constants.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/temperature_utils.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final cartItems = orderProvider.cartItems;
    final cartSubtotal = orderProvider.cartSubtotal;
    final deliveryFee = 4.99;
    final tax = cartSubtotal * 0.10; // 10% tax rate
    final total = cartSubtotal + deliveryFee + tax;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Are you sure you want to remove all items from your cart?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          orderProvider.clearCart();
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cart cleared')),
                          );
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? _buildEmptyCart()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (ctx, index) {
                          final cartItem = cartItems[index];
                          final product = productProvider.findProductById(cartItem.productId);
                          
                          if (product == null) {
                            return const SizedBox.shrink();
                          }
                          
                          return _buildCartItem(context, product, cartItem, orderProvider);
                        },
                      ),
                    ),
                    _buildOrderSummary(
                      cartSubtotal: cartSubtotal,
                      deliveryFee: deliveryFee,
                      tax: tax,
                      total: total,
                    ),
                  ],
                ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppConstants.checkoutRoute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add products to your cart to get started',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    Product product,
    OrderItem cartItem,
    OrderProvider orderProvider,
  ) {
    final zoneName = product.temperatureRequirement.zone.toString().split('.').last;
    final zoneColor = TemperatureUtils.getTemperatureZoneColor(zoneName);
    final zoneIcon = TemperatureUtils.getTemperatureZoneIcon(zoneName);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.imageUrl ?? 'https://placehold.co/400x300/EAEAEA/CCCCCC?text=No+Image',
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error_outline, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: zoneColor,
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Icon(
                          zoneIcon,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product details
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
                      color: AppConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildQuantityControl(
                        context,
                        cartItem.quantity,
                        (newQuantity) {
                          orderProvider.updateCartItemQuantity(
                            product.id,
                            newQuantity,
                          );
                        },
                      ),
                      const Spacer(),
                      Text(
                        '\$${(product.price * cartItem.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Remove button
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: () {
                orderProvider.removeFromCart(product.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} removed from cart'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        orderProvider.addToCart(product, 1);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControl(
    BuildContext context,
    int currentQuantity,
    Function(int) onQuantityChanged,
  ) {
    return Row(
      children: [
        _buildQuantityButton(
          context,
          Icons.remove,
          () {
            if (currentQuantity > 1) {
              onQuantityChanged(currentQuantity - 1);
            }
          },
          currentQuantity <= 1,
        ),
        Container(
          width: 40,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$currentQuantity',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        _buildQuantityButton(
          context,
          Icons.add,
          () {
            onQuantityChanged(currentQuantity + 1);
          },
          false,
        ),
      ],
    );
  }

  Widget _buildQuantityButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
    bool isDisabled,
  ) {
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isDisabled
            ? Colors.grey.shade200
            : AppConstants.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 16,
          color: isDisabled
              ? Colors.grey.shade400
              : AppConstants.primaryColor,
        ),
        onPressed: isDisabled ? null : onPressed,
      ),
    );
  }

  Widget _buildOrderSummary({
    required double cartSubtotal,
    required double deliveryFee,
    required double tax,
    required double total,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.defaultBorderRadius),
          topRight: Radius.circular(AppConstants.defaultBorderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
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
} 