import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/compartment.dart';
import '../../providers/compartment_provider.dart';
import '../../providers/product_provider.dart';

class CompartmentDetailsScreen extends StatefulWidget {
  final Compartment compartment;

  const CompartmentDetailsScreen({
    Key? key,
    required this.compartment,
  }) : super(key: key);

  @override
  State<CompartmentDetailsScreen> createState() => _CompartmentDetailsScreenState();
}

class _CompartmentDetailsScreenState extends State<CompartmentDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.compartment.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Products'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Details tab
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDetailCard(
                'Description',
                widget.compartment.description,
                Icons.description,
              ),
              const SizedBox(height: 16),
              _buildDetailCard(
                'Temperature Zone',
                widget.compartment.temperatureZone.toString().split('.').last,
                Icons.thermostat,
              ),
              const SizedBox(height: 16),
              _buildDetailCard(
                'Capacity',
                '${widget.compartment.capacity} m³',
                Icons.storage,
              ),
              const SizedBox(height: 16),
              _buildDetailCard(
                'Temperature Range',
                '${widget.compartment.minTemperature}°C - ${widget.compartment.maxTemperature}°C',
                Icons.thermostat_auto,
              ),
              const SizedBox(height: 16),
              _buildDetailCard(
                'Current Temperature',
                '${widget.compartment.currentTemperature}°C',
                Icons.thermostat_auto,
              ),
              const SizedBox(height: 16),
              _buildDetailCard(
                'Status',
                widget.compartment.status.toString().split('.').last,
                _getStatusIcon(widget.compartment.status),
              ),
              if (widget.compartment.lastMaintenanceDate != null) ...[
                const SizedBox(height: 16),
                _buildDetailCard(
                  'Last Maintenance',
                  _formatDate(widget.compartment.lastMaintenanceDate!),
                  Icons.build,
                ),
              ],
              if (widget.compartment.nextMaintenanceDate != null) ...[
                const SizedBox(height: 16),
                _buildDetailCard(
                  'Next Maintenance',
                  _formatDate(widget.compartment.nextMaintenanceDate!),
                  Icons.schedule,
                ),
              ],
            ],
          ),
          // Products tab
          Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(productProvider.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Retry loading products
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final products = productProvider.products
                  .where((product) => widget.compartment.productIds?.contains(product.id) ?? false)
                  .toList();

              if (products.isEmpty) {
                return const Center(
                  child: Text('No products in this compartment'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl ?? 'https://via.placeholder.com/56',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 56,
                              height: 56,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            );
                          },
                        ),
                      ),
                      title: Text(product.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.description),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildInfoChip(
                                '${product.price} USD',
                                Icons.attach_money,
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                'Stock: ${product.stockQuantity}',
                                Icons.inventory,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(CompartmentStatus status) {
    switch (status) {
      case CompartmentStatus.available:
        return Icons.check_circle;
      case CompartmentStatus.occupied:
        return Icons.inventory;
      case CompartmentStatus.maintenance:
        return Icons.build;
      case CompartmentStatus.reserved:
        return Icons.schedule;
    }
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Chip(
      label: Text(label),
      avatar: Icon(icon, size: 16),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 