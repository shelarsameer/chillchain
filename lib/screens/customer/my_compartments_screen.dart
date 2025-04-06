import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/compartment.dart';
import '../../providers/compartment_provider.dart';
import '../../providers/auth_provider.dart';
import 'compartment_details_screen.dart';

class MyCompartmentsScreen extends StatefulWidget {
  const MyCompartmentsScreen({Key? key}) : super(key: key);

  @override
  State<MyCompartmentsScreen> createState() => _MyCompartmentsScreenState();
}

class _MyCompartmentsScreenState extends State<MyCompartmentsScreen> {
  String _searchQuery = '';
  TemperatureZone? _selectedZone;

  @override
  void initState() {
    super.initState();
    _loadCompartments();
  }

  Future<void> _loadCompartments() async {
    final customerId = context.read<AuthProvider>().currentUser?.id;
    if (customerId != null) {
      await context.read<CompartmentProvider>().loadCompartments();
    }
  }

  List<Compartment> _getFilteredCompartments() {
    final provider = context.read<CompartmentProvider>();
    final customerId = context.read<AuthProvider>().currentUser?.id;
    
    if (customerId == null) return [];

    List<Compartment> compartments = provider.compartments
        .where((compartment) => compartment.currentCustomerId == customerId)
        .toList();

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      compartments = compartments.where((compartment) =>
        compartment.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        compartment.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply zone filter
    if (_selectedZone != null) {
      compartments = compartments.where((compartment) =>
        compartment.temperatureZone == _selectedZone
      ).toList();
    }

    return compartments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Compartments'),
      ),
      body: Column(
        children: [
          // Search and filter section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search compartments...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TemperatureZone>(
                  decoration: const InputDecoration(
                    labelText: 'Temperature Zone',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedZone,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Zones'),
                    ),
                    ...TemperatureZone.values.map((zone) {
                      return DropdownMenuItem(
                        value: zone,
                        child: Text(zone.toString().split('.').last),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedZone = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // Compartments list
          Expanded(
            child: Consumer<CompartmentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(provider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCompartments,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final compartments = _getFilteredCompartments();

                if (compartments.isEmpty) {
                  return const Center(
                    child: Text('No compartments assigned to you'),
                  );
                }

                return ListView.builder(
                  itemCount: compartments.length,
                  itemBuilder: (context, index) {
                    final compartment = compartments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Icon(
                          _getStatusIcon(compartment.status),
                          color: _getStatusColor(compartment.status),
                        ),
                        title: Text(compartment.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(compartment.description),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                _buildInfoChip(
                                  'Zone: ${compartment.temperatureZone.toString().split('.').last}',
                                  Icons.thermostat,
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  '${compartment.currentTemperature}°C',
                                  Icons.thermostat_auto,
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  '${compartment.capacity}m³',
                                  Icons.storage,
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'details',
                              child: Text('View Details'),
                            ),
                            const PopupMenuItem(
                              value: 'products',
                              child: Text('View Products'),
                            ),
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'details':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CompartmentDetailsScreen(
                                      compartment: compartment,
                                    ),
                                  ),
                                );
                                break;
                              case 'products':
                                // TODO: Navigate to products in compartment screen
                                break;
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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

  Color _getStatusColor(CompartmentStatus status) {
    switch (status) {
      case CompartmentStatus.available:
        return Colors.green;
      case CompartmentStatus.occupied:
        return Colors.blue;
      case CompartmentStatus.maintenance:
        return Colors.orange;
      case CompartmentStatus.reserved:
        return Colors.purple;
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
} 