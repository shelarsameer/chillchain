import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../constants/app_constants.dart';
import '../../models/storage.dart';
import '../../models/user.dart';
import '../../providers/storage_provider.dart';
import 'facility_verification_detail_screen.dart';

class FacilityVerificationScreen extends StatefulWidget {
  const FacilityVerificationScreen({Key? key}) : super(key: key);

  @override
  _FacilityVerificationScreenState createState() => _FacilityVerificationScreenState();
}

class _FacilityVerificationScreenState extends State<FacilityVerificationScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  List<StorageFacility> _pendingFacilities = [];
  List<StorageFacility> _approvedFacilities = [];
  List<StorageFacility> _rejectedFacilities = [];
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFacilities();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadFacilities() async {
    setState(() => _isLoading = true);
    
    try {
      // In a real app, these would come from the StorageProvider
      // For demo, we'll create mock data
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
      
      setState(() {
        _pendingFacilities = _generateMockPendingFacilities();
        _approvedFacilities = _generateMockApprovedFacilities();
        _rejectedFacilities = _generateMockRejectedFacilities();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading facilities: $e');
      setState(() => _isLoading = false);
    }
  }

  List<StorageFacility> _generateMockPendingFacilities() {
    return [
      StorageFacility(
        id: 'pf1',
        name: 'MountainView Cold Storage',
        ownerId: 'vendor4',
        address: Address(
          id: 'addr4',
          streetAddress: '123 Mountain View Rd',
          city: 'Boulder',
          state: 'CO',
          postalCode: '80303',
          country: 'USA',
          latitude: 40.0150,
          longitude: -105.2705,
        ),
        licenseNumber: 'CS-2023-PENDING-001',
        contactPhone: '555-123-9876',
        compartments: [],
        isVerified: false,
        hourlyRates: {'frozen': 2.5, 'chilled': 2.0, 'cool': 1.5},
        dailyRates: {'frozen': 45.0, 'chilled': 35.0, 'cool': 25.0},
        monthlyRates: {'frozen': 1200.0, 'chilled': 900.0, 'cool': 700.0},
        description: 'New state-of-the-art cold storage facility serving the mountain regions',
      ),
      StorageFacility(
        id: 'pf2',
        name: 'ValleyFresh Storage',
        ownerId: 'vendor5',
        address: Address(
          id: 'addr5',
          streetAddress: '456 Valley Way',
          city: 'Sacramento',
          state: 'CA',
          postalCode: '95814',
          country: 'USA',
          latitude: 38.5816,
          longitude: -121.4944,
        ),
        licenseNumber: 'CS-2023-PENDING-002',
        contactPhone: '555-987-6543',
        compartments: [],
        isVerified: false,
        hourlyRates: {'frozen': 2.7, 'chilled': 2.2, 'cool': 1.7},
        dailyRates: {'frozen': 50.0, 'chilled': 40.0, 'cool': 30.0},
        monthlyRates: {'frozen': 1300.0, 'chilled': 1000.0, 'cool': 800.0},
        description: 'Valley\'s premier cold storage solution for agricultural products',
      ),
    ];
  }

  List<StorageFacility> _generateMockApprovedFacilities() {
    return [
      StorageFacility(
        id: 'af1',
        name: 'Arctic Cold Storage',
        ownerId: 'vendor1',
        address: Address(
          id: 'addr1',
          streetAddress: '123 Freeze Lane',
          city: 'Cooltown',
          state: 'Refrigerator',
          postalCode: '12345',
          country: 'USA',
          latitude: 37.7749,
          longitude: -122.4194,
        ),
        licenseNumber: 'CS-2023-001',
        contactPhone: '555-123-4567',
        compartments: [],
        isVerified: true,
        hourlyRates: {'frozen': 2.5, 'chilled': 2.0, 'cool': 1.5},
        dailyRates: {'frozen': 45.0, 'chilled': 35.0, 'cool': 25.0},
        monthlyRates: {'frozen': 1200.0, 'chilled': 900.0, 'cool': 700.0},
        description: 'State-of-the-art cold storage facility with multiple temperature zones',
      ),
    ];
  }

  List<StorageFacility> _generateMockRejectedFacilities() {
    return [
      StorageFacility(
        id: 'rf1',
        name: 'QuickFreeze Storage',
        ownerId: 'vendor6',
        address: Address(
          id: 'addr6',
          streetAddress: '789 Cold Street',
          city: 'Frostville',
          state: 'AK',
          postalCode: '99501',
          country: 'USA',
          latitude: 61.2181,
          longitude: -149.9003,
        ),
        licenseNumber: 'CS-2023-REJECTED-001',
        contactPhone: '555-333-4444',
        compartments: [],
        isVerified: false,
        hourlyRates: {'frozen': 2.0, 'chilled': 1.5, 'cool': 1.0},
        dailyRates: {'frozen': 40.0, 'chilled': 30.0, 'cool': 20.0},
        monthlyRates: {'frozen': 1000.0, 'chilled': 800.0, 'cool': 600.0},
        description: 'Rejected due to insufficient temperature control documentation',
      ),
    ];
  }
  
  Future<void> _approveFacility(StorageFacility facility) async {
    // In a real app, call the provider to update the facility status
    setState(() {
      _pendingFacilities.removeWhere((f) => f.id == facility.id);
      _approvedFacilities.add(
        StorageFacility(
          id: facility.id,
          name: facility.name,
          ownerId: facility.ownerId,
          address: facility.address,
          licenseNumber: facility.licenseNumber,
          contactPhone: facility.contactPhone,
          compartments: facility.compartments,
          isVerified: true, // Now verified
          rating: facility.rating,
          totalRatings: facility.totalRatings,
          images: facility.images,
          description: facility.description,
          hourlyRates: facility.hourlyRates,
          dailyRates: facility.dailyRates,
          monthlyRates: facility.monthlyRates,
          reviews: facility.reviews,
        ),
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${facility.name} has been approved')),
    );
  }
  
  Future<void> _rejectFacility(StorageFacility facility, String reason) async {
    // In a real app, call the provider to update the facility status
    setState(() {
      _pendingFacilities.removeWhere((f) => f.id == facility.id);
      _rejectedFacilities.add(
        StorageFacility(
          id: facility.id,
          name: facility.name,
          ownerId: facility.ownerId,
          address: facility.address,
          licenseNumber: facility.licenseNumber,
          contactPhone: facility.contactPhone,
          compartments: facility.compartments,
          isVerified: false,
          rating: facility.rating,
          totalRatings: facility.totalRatings,
          images: facility.images,
          description: '${facility.description}\n\nRejection reason: $reason',
          hourlyRates: facility.hourlyRates,
          dailyRates: facility.dailyRates,
          monthlyRates: facility.monthlyRates,
          reviews: facility.reviews,
        ),
      );
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${facility.name} has been rejected')),
    );
  }

  void _showRejectionDialog(StorageFacility facility) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Facility'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a rejection reason')),
                );
                return;
              }
              
              Navigator.pop(context);
              _rejectFacility(facility, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
  
  void _viewFacilityDetails(StorageFacility facility) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FacilityVerificationDetailScreen(facility: facility),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppConstants.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPendingList(),
              _buildApprovedList(),
              _buildRejectedList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingList() {
    if (_pendingFacilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No pending verification requests',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadFacilities,
      child: ListView.builder(
        itemCount: _pendingFacilities.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final facility = _pendingFacilities[index];
          return _buildFacilityCard(
            facility,
            isPending: true,
          );
        },
      ),
    );
  }

  Widget _buildApprovedList() {
    if (_approvedFacilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No approved facilities',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadFacilities,
      child: ListView.builder(
        itemCount: _approvedFacilities.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final facility = _approvedFacilities[index];
          return _buildFacilityCard(
            facility,
            isApproved: true,
          );
        },
      ),
    );
  }

  Widget _buildRejectedList() {
    if (_rejectedFacilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No rejected facilities',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadFacilities,
      child: ListView.builder(
        itemCount: _rejectedFacilities.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final facility = _rejectedFacilities[index];
          return _buildFacilityCard(
            facility,
            isRejected: true,
          );
        },
      ),
    );
  }

  Widget _buildFacilityCard(
    StorageFacility facility, {
    bool isPending = false,
    bool isApproved = false,
    bool isRejected = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: isPending
                  ? Colors.orange
                  : isApproved
                      ? Colors.green
                      : Colors.red,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isPending
                      ? Icons.pending
                      : isApproved
                          ? Icons.verified
                          : Icons.cancel,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isPending
                      ? 'Pending Verification'
                      : isApproved
                          ? 'Approved'
                          : 'Rejected',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isPending)
                  Text(
                    'Submitted: ${DateFormat('MMM d, yyyy').format(DateTime.now().subtract(const Duration(days: 3)))}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          
          // Facility details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Facility icon or placeholder
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.warehouse,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            facility.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            facility.address.fullAddress,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                facility.contactPhone,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // License info
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'License Number:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            facility.licenseNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // View details button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Details'),
                      onPressed: () => _viewFacilityDetails(facility),
                    ),
                    const SizedBox(width: 8),
                    
                    // Approval/rejection buttons for pending facilities
                    if (isPending) ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: const Text('Reject'),
                        onPressed: () => _showRejectionDialog(facility),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Approve'),
                        onPressed: () => _approveFacility(facility),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 