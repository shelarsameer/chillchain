import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/compartment.dart';
import '../../providers/compartment_provider.dart';
import '../../constants/app_constants.dart';
import 'add_edit_compartment_screen.dart';

class CompartmentManagementScreen extends StatefulWidget {
  const CompartmentManagementScreen({Key? key}) : super(key: key);

  @override
  State<CompartmentManagementScreen> createState() => _CompartmentManagementScreenState();
}

class _CompartmentManagementScreenState extends State<CompartmentManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  TemperatureZone? _selectedZone;
  CompartmentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCompartments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCompartments() async {
    await context.read<CompartmentProvider>().loadCompartments();
  }

  List<Compartment> _getFilteredCompartments() {
    final provider = context.read<CompartmentProvider>();
    List<Compartment> compartments = provider.compartments;

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

    // Apply status filter
    if (_selectedStatus != null) {
      compartments = compartments.where((compartment) =>
        compartment.status == _selectedStatus
      ).toList();
    }

    return compartments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compartment Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Available'),
            Tab(text: 'Occupied'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditCompartmentScreen(),
                ),
              ).then((_) => _loadCompartments());
            },
          ),
        ],
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<TemperatureZone>(
                        decoration: const InputDecoration(
                          labelText: 'Temperature Zone',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedZone,
                        items: TemperatureZone.values.map((zone) {
                          return DropdownMenuItem(
                            value: zone,
                            child: Text(zone.toString().split('.').last),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedZone = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<CompartmentStatus>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedStatus,
                        items: CompartmentStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.toString().split('.').last),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value;
                          });
                        },
                      ),
                    ),
                  ],
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
                    child: Text('No compartments found'),
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
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'maintenance',
                              child: Text('Maintenance'),
                            ),
                            if (compartment.status == CompartmentStatus.occupied)
                              const PopupMenuItem(
                                value: 'release',
                                child: Text('Release'),
                              ),
                          ],
                          onSelected: (value) async {
                            switch (value) {
                              case 'edit':
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditCompartmentScreen(
                                      compartment: compartment,
                                    ),
                                  ),
                                ).then((_) => _loadCompartments());
                                break;
                              case 'maintenance':
                                await provider.updateCompartmentStatus(
                                  compartment.id,
                                  CompartmentStatus.maintenance,
                                );
                                break;
                              case 'release':
                                await provider.releaseCompartmentFromOrder(
                                  compartment.id,
                                );
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