import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../constants/app_constants.dart';
import '../../models/storage.dart';
import '../../models/product.dart';
import '../../models/storage_booking.dart';
import '../../providers/storage_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/temperature_utils.dart';
import '../../widgets/temperature_display.dart';
import 'book_storage_screen.dart';

class StorageFacilityDetailScreen extends StatefulWidget {
  final String facilityId;
  
  const StorageFacilityDetailScreen({
    Key? key,
    required this.facilityId,
  }) : super(key: key);

  @override
  _StorageFacilityDetailScreenState createState() => _StorageFacilityDetailScreenState();
}

class _StorageFacilityDetailScreenState extends State<StorageFacilityDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFacilityDetails();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFacilityDetails() async {
    setState(() => _isLoading = true);
    
    try {
      final storageProvider = Provider.of<StorageProvider>(context, listen: false);
      await storageProvider.fetchFacilityById(widget.facilityId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading facility: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToBooking(StorageFacility facility) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookStorageScreen(facility: facility),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StorageProvider>(
      builder: (context, storageProvider, child) {
        final facility = storageProvider.selectedFacility;
        
        if (_isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (facility == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Facility Details')),
            body: const Center(child: Text('Facility not found')),
          );
        }
        
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      facility.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: facility.images.isNotEmpty
                        ? Image.network(
                            facility.images.first,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppConstants.primaryColor,
                            child: const Center(
                              child: Icon(
                                Icons.warehouse,
                                size: 80,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.star_border),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Facility saved to favorites')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share functionality coming soon')),
                        );
                      },
                    ),
                  ],
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Compartments'),
                        Tab(text: 'Rates'),
                        Tab(text: 'Reviews'),
                      ],
                      labelColor: AppConstants.primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppConstants.primaryColor,
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: Column(
              children: [
                // Facility overview
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  facility.address.fullAddress,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 18),
                                    Text(
                                      ' ${facility.rating.toStringAsFixed(1)} (${facility.reviews.length} reviews)',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.phone),
                                label: const Text('Call'),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Calling ${facility.phoneNumber}')),
                                  );
                                },
                              ),
                              Text(
                                facility.phoneNumber,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Available Temperature Zones:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildTemperatureZoneChips(facility),
                      const SizedBox(height: 16),
                      if (facility.description.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'About this facility:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(facility.description),
                          ],
                        ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCompartmentsTab(facility),
                      _buildRatesTab(facility),
                      _buildReviewsTab(facility),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            elevation: 10,
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 80,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Need storage space?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Rates from \$${_getLowestRate(facility)}/day',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => _navigateToBooking(facility),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Book Now'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTemperatureZoneChips(StorageFacility facility) {
    // Get available temperature zones from compartments
    final zones = facility.compartments
        .map((comp) => comp.temperatureZone)
        .toSet()
        .toList();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: zones.map((zone) {
        return Chip(
          label: Text(zone.toString().split('.').last),
          backgroundColor: getTemperatureZoneColor(zone).withOpacity(0.2),
        );
      }).toList(),
    );
  }

  Widget _buildCompartmentsTab(StorageFacility facility) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: facility.compartments.length,
      itemBuilder: (context, index) {
        final compartment = facility.compartments[index];
        final availability = compartment.isAvailable ? 
            'Available (${compartment.availableCapacity.toStringAsFixed(1)} m³)' : 
            'Currently Full';
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        compartment.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: compartment.isAvailable ? 
                            Colors.green.withOpacity(0.2) : 
                            Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        availability,
                        style: TextStyle(
                          color: compartment.isAvailable ? 
                              Colors.green[800] : 
                              Colors.red[800],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.thermostat, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      compartment.temperatureZone.toString().split('.').last,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.straighten, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${compartment.capacity.toStringAsFixed(1)} m³',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.device_thermostat, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Current Temp: ${compartment.currentTemperature.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontSize: 14,
                        color: _getTemperatureStatusColor(compartment.temperatureStatus),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Temperature Monitoring:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: 0.7, // Example temperature monitoring progress
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getTemperatureStatusColor(compartment.temperatureStatus),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  compartment.temperatureStatus == TemperatureStatus.normal ?
                    'Temperature is within optimal range' :
                    'Temperature needs adjustment',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTemperatureStatusColor(compartment.temperatureStatus),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRatesTab(StorageFacility facility) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Storage Rates',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRateCard(
            'Hourly Rates',
            Icons.access_time,
            facility.hourlyRates,
          ),
          const SizedBox(height: 16),
          _buildRateCard(
            'Daily Rates',
            Icons.calendar_today,
            facility.dailyRates,
          ),
          const SizedBox(height: 16),
          _buildRateCard(
            'Monthly Rates',
            Icons.calendar_month,
            facility.monthlyRates,
          ),
          const SizedBox(height: 24),
          const Text(
            'Additional Fees:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('• Loading/Unloading: \$25 per operation'),
          const Text('• Late Payment Fee: 2% of outstanding amount'),
          const Text('• Early Termination: 20% of remaining contract value'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'All rates are per cubic meter. Discounts available for long-term bookings and bulk storage.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard(String title, IconData icon, Map<String, double> rates) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: rates.entries.map((entry) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab(StorageFacility facility) {
    if (facility.reviews.isEmpty) {
      return const Center(
        child: Text('No reviews yet for this facility'),
      );
    }
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        facility.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStarRating(facility.rating),
                          Text(
                            '${facility.reviews.length} reviews',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Write a review feature coming soon'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppConstants.primaryColor,
                  side: BorderSide(color: AppConstants.primaryColor),
                ),
                child: const Text('Write a Review'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            itemCount: facility.reviews.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final review = facility.reviews[index];
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          child: Icon(Icons.person, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(review.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        _buildStarRating(review.rating, size: 16),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(review.comment),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating(double rating, {double size = 18}) {
    return Row(
      children: List.generate(5, (index) {
        final double value = rating - index;
        IconData icon;
        if (value >= 1) {
          icon = Icons.star;
        } else if (value >= 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }
        return Icon(icon, color: Colors.amber, size: size);
      }),
    );
  }

  double _getLowestRate(StorageFacility facility) {
    final lowestDaily = facility.dailyRates.values.reduce(
      (value, element) => value < element ? value : element,
    );
    return lowestDaily;
  }

  Color _getTemperatureStatusColor(TemperatureStatus status) {
    switch (status) {
      case TemperatureStatus.normal:
        return Colors.green;
      case TemperatureStatus.warning:
        return Colors.orange;
      case TemperatureStatus.outOfRange:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  
  _SliverAppBarDelegate(this._tabBar);
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  
  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
} 