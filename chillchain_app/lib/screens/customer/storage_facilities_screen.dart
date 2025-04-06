import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../../constants/app_constants.dart';
import '../../models/storage.dart';
import '../../models/product.dart';
import '../../providers/storage_provider.dart';
import '../../widgets/temperature_display.dart';
import 'storage_facility_detail_screen.dart';

class StorageFacilitiesScreen extends StatefulWidget {
  const StorageFacilitiesScreen({Key? key}) : super(key: key);

  @override
  _StorageFacilitiesScreenState createState() => _StorageFacilitiesScreenState();
}

class _StorageFacilitiesScreenState extends State<StorageFacilitiesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isNearbyFilterActive = false;
  TemperatureZone? _selectedZone;
  double _maxDistance = 50.0; // km

  @override
  void initState() {
    super.initState();
    _loadFacilities();
    
    _searchController.addListener(() {
      final provider = Provider.of<StorageProvider>(context, listen: false);
      provider.setSearchTerm(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilities() async {
    final provider = Provider.of<StorageProvider>(context, listen: false);
    await provider.fetchAllFacilities();
  }

  Future<void> _findNearbyFacilities() async {
    setState(() => _isNearbyFilterActive = true);
    
    try {
      // Request location permission
      bool serviceEnabled;
      LocationPermission permission;
      
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.'))
        );
        setState(() => _isNearbyFilterActive = false);
        return;
      }
      
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.'))
          );
          setState(() => _isNearbyFilterActive = false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied.'))
        );
        setState(() => _isNearbyFilterActive = false);
        return;
      }
      
      // Get the current position
      final position = await Geolocator.getCurrentPosition();
      
      // Fetch nearby facilities
      final provider = Provider.of<StorageProvider>(context, listen: false);
      await provider.fetchNearbyFacilities(position.latitude, position.longitude);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Showing storage facilities within ${provider.maxDistanceKm} km.'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding nearby facilities: $e'))
      );
      setState(() => _isNearbyFilterActive = false);
    }
  }

  void _filterByZone(TemperatureZone? zone) {
    setState(() => _selectedZone = zone);
    
    final provider = Provider.of<StorageProvider>(context, listen: false);
    if (zone != null) {
      provider.fetchFacilitiesByZone(zone);
    } else {
      provider.fetchAllFacilities();
    }
  }

  void _resetFilters() {
    setState(() {
      _isNearbyFilterActive = false;
      _selectedZone = null;
      _searchController.clear();
    });
    
    final provider = Provider.of<StorageProvider>(context, listen: false);
    provider.resetFilters();
    provider.fetchAllFacilities();
  }

  void _showSearchBar() {
    setState(() => _isSearching = true);
  }

  void _hideSearchBar() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    
    final provider = Provider.of<StorageProvider>(context, listen: false);
    provider.setSearchTerm('');
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<StorageProvider>(
          builder: (context, provider, _) {
            return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Filter Options'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Temperature Zone:'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All'),
                            selected: _selectedZone == null,
                            onSelected: (selected) {
                              if (selected) {
                                setDialogState(() => _selectedZone = null);
                              }
                            },
                          ),
                          ...TemperatureZone.values.map((zone) {
                            return FilterChip(
                              label: Text(zone.toString().split('.').last),
                              selected: _selectedZone == zone,
                              onSelected: (selected) {
                                if (selected) {
                                  setDialogState(() => _selectedZone = zone);
                                }
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Maximum Distance (for nearby search):'),
                      Slider(
                        value: provider.maxDistanceKm,
                        min: 5,
                        max: 100,
                        divisions: 19,
                        label: '${provider.maxDistanceKm.round()} km',
                        onChanged: (value) {
                          setDialogState(() {
                            _maxDistance = value;
                            provider.setMaxDistance(value);
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _filterByZone(_selectedZone);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search storage facilities...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                autofocus: true,
              )
            : const Text('Cold Storage Facilities'),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _hideSearchBar,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearchBar,
            ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<StorageProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadFacilities,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          
          final facilities = provider.filteredFacilities;
          
          if (facilities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No storage facilities found.'),
                  const SizedBox(height: 16),
                  if (_isNearbyFilterActive || _selectedZone != null || _searchController.text.isNotEmpty)
                    ElevatedButton(
                      onPressed: _resetFilters,
                      child: const Text('Reset Filters'),
                    ),
                ],
              ),
            );
          }
          
          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: facilities.length,
                itemBuilder: (context, index) {
                  final facility = facilities[index];
                  return FacilityCard(
                    facility: facility,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StorageFacilityDetailScreen(facilityId: facility.id),
                        ),
                      );
                    },
                  );
                },
              ),
              if (_isNearbyFilterActive || _selectedZone != null || _searchController.text.isNotEmpty)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.clear),
                      label: const Text('Reset Filters'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _findNearbyFacilities,
        icon: const Icon(Icons.near_me),
        label: const Text('Nearby'),
        backgroundColor: _isNearbyFilterActive ? Colors.green : AppConstants.primaryColor,
      ),
    );
  }
}

class FacilityCard extends StatelessWidget {
  final StorageFacility facility;
  final VoidCallback onTap;

  const FacilityCard({
    Key? key,
    required this.facility,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (facility.images.isNotEmpty)
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.network(
                  facility.images.first,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 160,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          facility.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (facility.isVerified)
                        const Tooltip(
                          message: 'Verified Facility',
                          child: Icon(Icons.verified, color: Colors.green),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    facility.address.fullAddress,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${facility.rating} (${facility.totalRatings})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${facility.availableCapacity.toStringAsFixed(1)} m³ available',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Available Zones:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildAvailableZones(facility),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: onTap,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAvailableZones(StorageFacility facility) {
    final Map<TemperatureZone, bool> zoneMap = {};
    
    // Collect all available temperature zones with available capacity
    for (final compartment in facility.compartments) {
      if (compartment.isAvailable && compartment.availableCapacity > 0) {
        zoneMap[compartment.temperatureZone] = true;
      }
    }
    
    // Create chip for each available zone
    return zoneMap.keys.map((zone) {
      Color chipColor;
      IconData zoneIcon;
      
      switch (zone) {
        case TemperatureZone.frozen:
          chipColor = Colors.blue;
          zoneIcon = Icons.ac_unit;
          break;
        case TemperatureZone.chilled:
          chipColor = Colors.cyan;
          zoneIcon = Icons.thermostat;
          break;
        case TemperatureZone.cool:
          chipColor = Colors.green;
          zoneIcon = Icons.wb_twilight;
          break;
        case TemperatureZone.ambient:
          chipColor = Colors.orange;
          zoneIcon = Icons.wb_sunny;
          break;
      }
      
      return Chip(
        avatar: Icon(zoneIcon, color: Colors.white, size: 18),
        label: Text(
          zone.toString().split('.').last,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: chipColor,
      );
    }).toList();
  }
} 