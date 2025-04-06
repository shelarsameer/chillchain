import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../constants/app_constants.dart';
import '../../models/storage.dart';
import '../../models/product.dart';
import '../../models/storage_booking.dart';
import '../../models/user.dart';
import '../../providers/storage_provider.dart';
import '../../utils/temperature_utils.dart';
import '../../widgets/temperature_display.dart';

class FacilityManagementScreen extends StatefulWidget {
  final String facilityId;
  
  const FacilityManagementScreen({
    Key? key,
    required this.facilityId,
  }) : super(key: key);

  @override
  _FacilityManagementScreenState createState() => _FacilityManagementScreenState();
}

class _FacilityManagementScreenState extends State<FacilityManagementScreen> {
  bool _isLoading = true;
  StorageFacility? _facility;

  @override
  void initState() {
    super.initState();
    _loadFacility();
  }

  Future<void> _loadFacility() async {
    // In a real app, load from provider
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    setState(() {
      _isLoading = false;
      // This is temporary until we implement the real loading
      _facility = StorageFacility(
        id: 'demo-facility-1',
        name: 'Cold Storage Facility',
        ownerId: 'demo-vendor',
        address: Address(
          id: '1',
          streetAddress: '123 Main St',
          city: 'Anytown',
          state: 'CA',
          postalCode: '12345',
          country: 'USA',
          latitude: 37.7749,
          longitude: -122.4194,
        ),
        licenseNumber: 'CS-12345',
        contactPhone: '555-123-4567',
        compartments: [],
        isVerified: true,
        rating: 4.5,
        reviews: [],
        images: [],
        description: 'A modern cold storage facility',
        hourlyRates: {'Frozen': 2.5, 'Chilled': 1.5, 'Ambient': 1.0},
        dailyRates: {'Frozen': 20.0, 'Chilled': 15.0, 'Ambient': 10.0},
        monthlyRates: {'Frozen': 500.0, 'Chilled': 400.0, 'Ambient': 300.0},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_facility == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Facility Management'),
        ),
        body: const Center(
          child: Text('Error loading facility'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_facility!.name),
      ),
      body: Center(
        child: Text('Facility Management Screen - Under Construction'),
      ),
    );
  }
}

// In the _buildTemperatureZonesRow method
Widget _buildTemperatureZonesRow(StorageFacility facility) {
  // Group compartments by temperature zone
  final Map<TemperatureZone, int> zoneCount = {};
  
  for (final compartment in facility.compartments) {
    if (zoneCount.containsKey(compartment.temperatureZone)) {
      zoneCount[compartment.temperatureZone] = zoneCount[compartment.temperatureZone]! + 1;
    } else {
      zoneCount[compartment.temperatureZone] = 1;
    }
  }
  
  return Row(
    children: TemperatureZone.values.map((zone) {
      final count = zoneCount[zone] ?? 0;
      if (count == 0) return const SizedBox.shrink();
      
      return Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Chip(
          avatar: CircleAvatar(
            backgroundColor: getColorForTemperatureZone(zone),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
          label: Text(zone.toString().split('.').last),
          backgroundColor: getColorForTemperatureZone(zone).withOpacity(0.1),
        ),
      );
    }).toList(),
  );
} 