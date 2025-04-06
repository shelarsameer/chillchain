import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../utils/app_constants.dart';
import '../../utils/date_time_utils.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _refreshOrderData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final updatedOrder = await orderProvider.getOrderById(_order.id);
      
      if (updatedOrder != null) {
        setState(() {
          _order = updatedOrder;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing order: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_order.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrderData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshOrderData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderStatusCard(),
                    const SizedBox(height: 16),
                    _buildCustomerInfoCard(),
                    const SizedBox(height: 16),
                    _buildOrderItemsList(),
                    const SizedBox(height: 16),
                    _buildOrderSummary(),
                    const SizedBox(height: 24),
                    if (_order.status != OrderStatus.delivered && 
                        _order.status != OrderStatus.cancelled)
                      _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderStatusCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildOrderTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTimeline() {
    return Column(
      children: [
        _buildTimelineItem(
          OrderStatus.pending,
          'Order Placed',
          DateTimeUtils.formatDateTime(_order.orderDate),
          _order.status.index >= OrderStatus.pending.index,
        ),
        _buildTimelineItem(
          OrderStatus.confirmed,
          'Order Confirmed',
          _order.statusChanges[OrderStatus.confirmed.toString()] != null
              ? DateTimeUtils.formatDateTime(_order.statusChanges[OrderStatus.confirmed.toString()]!)
              : '-',
          _order.status.index >= OrderStatus.confirmed.index,
        ),
        _buildTimelineItem(
          OrderStatus.assigned,
          'Delivery Assigned',
          _order.statusChanges[OrderStatus.assigned.toString()] != null
              ? DateTimeUtils.formatDateTime(_order.statusChanges[OrderStatus.assigned.toString()]!)
              : '-',
          _order.status.index >= OrderStatus.assigned.index,
        ),
        _buildTimelineItem(
          OrderStatus.outForDelivery,
          'Out for Delivery',
          _order.statusChanges[OrderStatus.outForDelivery.toString()] != null
              ? DateTimeUtils.formatDateTime(_order.statusChanges[OrderStatus.outForDelivery.toString()]!)
              : '-',
          _order.status.index >= OrderStatus.outForDelivery.index,
        ),
        _buildTimelineItem(
          OrderStatus.delivered,
          'Delivered',
          _order.statusChanges[OrderStatus.delivered.toString()] != null
              ? DateTimeUtils.formatDateTime(_order.statusChanges[OrderStatus.delivered.toString()]!)
              : '-',
          _order.status.index >= OrderStatus.delivered.index,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(OrderStatus status, String title, String timestamp, bool isCompleted, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
                border: Border.all(
                  color: isCompleted ? Colors.green.shade700 : Colors.grey,
                  width: 2,
                ),
              ),
              child: isCompleted 
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.black : Colors.grey,
                ),
              ),
              Text(
                timestamp,
                style: TextStyle(
                  fontSize: 12,
                  color: isCompleted ? Colors.grey.shade700 : Colors.grey.shade400,
                ),
              ),
              SizedBox(height: isLast ? 0 : 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.grey),
                const SizedBox(width: 8),
                Text(_order.customerName),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.grey),
                const SizedBox(width: 8),
                Text(_order.customerPhone ?? 'Not provided'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_order.deliveryAddress?.fullAddress ?? 'No delivery address provided'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsList() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _order.items.length,
              itemBuilder: (context, index) {
                final item = _order.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(item.product?.imageUrl ?? 'https://placehold.co/400x300/EAEAEA/CCCCCC?text=No+Image'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product?.name ?? 'Unknown Product',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${item.quantity} × \$${item.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${(item.quantity * item.price).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal'),
                Text('\$${_order.subtotal.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Delivery Fee'),
                Text('\$${_order.deliveryFee.toStringAsFixed(2)}'),
              ],
            ),
            if (_order.discount > 0) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Discount'),
                  Text('-\$${_order.discount.toStringAsFixed(2)}'),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '\$${_order.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _order.isPaid ? Icons.check_circle : Icons.pending,
                  color: _order.isPaid ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _order.isPaid ? 'Payment Completed' : 'Payment Pending',
                  style: TextStyle(
                    color: _order.isPaid ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            if (_order.paymentMethod != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.payment,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Payment Method: ${_order.paymentMethod}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_order.status == OrderStatus.pending)
          ElevatedButton.icon(
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirm Order'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _updateOrderStatus(OrderStatus.confirmed),
          ),
        
        if (_order.status == OrderStatus.confirmed)
          ElevatedButton.icon(
            icon: const Icon(Icons.local_shipping),
            label: const Text('Assign Delivery'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: _assignDelivery,
          ),
          
        if (_order.status != OrderStatus.cancelled && 
            _order.status != OrderStatus.delivered)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.cancel, color: Colors.red),
              label: const Text('Cancel Order'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              onPressed: () => _updateOrderStatus(OrderStatus.cancelled),
            ),
          ),
      ],
    );
  }

  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final success = await orderProvider.updateOrderStatus(_order.id, newStatus);
      
      if (success) {
        final updatedOrder = await orderProvider.getOrderById(_order.id);
        if (updatedOrder != null) {
          setState(() {
            _order = updatedOrder;
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${newStatus.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update order status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _assignDelivery() {
    // Show dialog to select delivery partner
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Delivery'),
        content: const Text('This feature will be available soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 