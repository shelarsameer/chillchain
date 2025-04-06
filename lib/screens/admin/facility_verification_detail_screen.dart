import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/app_constants.dart';
import '../../models/storage.dart';

class FacilityVerificationDetailScreen extends StatefulWidget {
  final StorageFacility facility;
  
  const FacilityVerificationDetailScreen({
    Key? key,
    required this.facility,
  }) : super(key: key);

  @override
  _FacilityVerificationDetailScreenState createState() => _FacilityVerificationDetailScreenState();
}

class _FacilityVerificationDetailScreenState extends State<FacilityVerificationDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: Text('Verify: ${widget.facility.name}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Documents'),
            Tab(text: 'Rates'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildDocumentsTab(),
          _buildRatesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildFacilityDetailsCard(),
          const SizedBox(height: 16),
          _buildOwnerDetailsCard(),
          const SizedBox(height: 16),
          _buildFacilitySpecificationsCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.facility.isVerified 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.facility.isVerified 
                    ? Icons.verified
                    : Icons.pending,
                color: widget.facility.isVerified 
                    ? Colors.green
                    : Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.facility.isVerified 
                      ? 'Verified Facility'
                      : 'Pending Verification',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.facility.isVerified 
                      ? 'This facility has been verified and is active'
                      : 'This facility is awaiting verification',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityDetailsCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: const Text(
              'Facility Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Name', widget.facility.name),
                const Divider(),
                _buildInfoRow('License Number', widget.facility.licenseNumber),
                const Divider(),
                _buildInfoRow('Contact Phone', widget.facility.contactPhone),
                const Divider(),
                _buildInfoRow(
                  'Address', 
                  widget.facility.address.fullAddress,
                ),
                const Divider(),
                _buildInfoRow(
                  'GPS Coordinates', 
                  '${widget.facility.address.latitude}, ${widget.facility.address.longitude}',
                ),
                const Divider(),
                _buildInfoRow(
                  'Description', 
                  widget.facility.description,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerDetailsCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: const Text(
              'Owner Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Owner ID', widget.facility.ownerId),
                const Divider(),
                _buildInfoRow('Owner Name', 'Jane Vendor'), // Mock data
                const Divider(),
                _buildInfoRow('Owner Email', 'vendor@example.com'), // Mock data
                const Divider(),
                _buildInfoRow('Business Type', 'Private Limited Company'), // Mock data
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitySpecificationsCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: const Text(
              'Facility Specifications',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Compartments', 
                  widget.facility.compartments.length.toString(),
                ),
                const Divider(),
                _buildInfoRow(
                  'Total Capacity', 
                  '${widget.facility.totalCapacity.toStringAsFixed(1)} m³',
                ),
                const Divider(),
                _buildInfoRow(
                  'Temperature Zones', 
                  _getTemperatureZones(),
                ),
                const Divider(),
                _buildInfoRow(
                  'Power Backup', 
                  'Yes - Generator + UPS', // Mock data
                ),
                const Divider(),
                _buildInfoRow(
                  'Temperature Monitoring', 
                  'Automated 24/7 with alerts', // Mock data
                ),
                const Divider(),
                _buildInfoRow(
                  'Security Features', 
                  'CCTV, Biometric Access, Security Staff', // Mock data
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTemperatureZones() {
    final Set<String> zones = {};
    
    // Get unique temperature zones from compartments
    for (final compartment in widget.facility.compartments) {
      zones.add(compartment.temperatureZone.toString().split('.').last);
    }
    
    // If no compartments, use the hourly rates keys as temperature zones
    if (zones.isEmpty) {
      zones.addAll(widget.facility.hourlyRates.keys);
    }
    
    return zones.join(', ');
  }

  Widget _buildDocumentsTab() {
    // In a real app, these would be actual uploaded documents
    final List<Map<String, dynamic>> documents = [
      {
        'name': 'Business Registration Certificate',
        'type': 'PDF',
        'size': '2.3 MB',
        'uploaded': DateTime.now().subtract(const Duration(days: 10)),
        'status': 'Verified',
        'icon': Icons.description,
      },
      {
        'name': 'Cold Storage License',
        'type': 'PDF',
        'size': '1.8 MB',
        'uploaded': DateTime.now().subtract(const Duration(days: 10)),
        'status': 'Pending',
        'icon': Icons.assignment,
      },
      {
        'name': 'Facility Floor Plan',
        'type': 'PDF',
        'size': '4.2 MB',
        'uploaded': DateTime.now().subtract(const Duration(days: 10)),
        'status': 'Verified',
        'icon': Icons.map,
      },
      {
        'name': 'Equipment Specifications',
        'type': 'PDF',
        'size': '3.1 MB',
        'uploaded': DateTime.now().subtract(const Duration(days: 10)),
        'status': 'Pending',
        'icon': Icons.settings,
      },
      {
        'name': 'Temperature Monitoring System',
        'type': 'PDF',
        'size': '2.7 MB',
        'uploaded': DateTime.now().subtract(const Duration(days: 10)),
        'status': 'Pending',
        'icon': Icons.thermostat,
      },
      {
        'name': 'Facility Photos',
        'type': 'ZIP',
        'size': '15.8 MB',
        'uploaded': DateTime.now().subtract(const Duration(days: 10)),
        'status': 'Verified',
        'icon': Icons.photo_library,
      },
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
              child: Icon(
                doc['icon'] as IconData,
                color: AppConstants.primaryColor,
              ),
            ),
            title: Text(doc['name'] as String),
            subtitle: Text(
              '${doc['type']} • ${doc['size']} • Uploaded ${DateFormat('MMM d, yyyy').format(doc['uploaded'] as DateTime)}',
            ),
            trailing: Chip(
              label: Text(
                doc['status'] as String,
                style: TextStyle(
                  color: (doc['status'] as String) == 'Verified' 
                      ? Colors.green 
                      : Colors.orange,
                  fontSize: 12,
                ),
              ),
              backgroundColor: (doc['status'] as String) == 'Verified' 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.orange.withOpacity(0.1),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Viewing ${doc['name']}')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRatesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRateCard('Hourly Rates', widget.facility.hourlyRates),
          const SizedBox(height: 16),
          _buildRateCard('Daily Rates', widget.facility.dailyRates),
          const SizedBox(height: 16),
          _buildRateCard('Monthly Rates', widget.facility.monthlyRates),
          const SizedBox(height: 24),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Service Charges',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('• Loading/Unloading: \$25 per operation'),
                  Text('• Cold Chain Packaging: \$10 per container'),
                  Text('• Temperature Monitoring Reports: \$5 per report'),
                  Text('• After-hours Access: \$15 per hour'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRateCard(String title, Map<String, dynamic> rates) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppConstants.primaryColor.withOpacity(0.1),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: rates.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${entry.key.toUpperCase()} Zone',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
} 