import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/product.dart';
import '../../models/user.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/temperature_display.dart';
import '../../models/storage.dart';
import '../../models/storage_booking.dart';
import '../../providers/storage_provider.dart';
import '../../utils/temperature_utils.dart';
import 'facility_management_screen.dart';

class VendorDashboardScreen extends StatefulWidget {
  const VendorDashboardScreen({Key? key}) : super(key: key);

  @override
  State<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends State<VendorDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  bool _isLoading = false;
  List<StorageFacility> _ownedFacilities = [];
  List<StorageBooking> _pendingBookings = [];
  List<StoredItem> _expiringItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final storageProvider = Provider.of<StorageProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      // Load orders
      await orderProvider.fetchVendorOrders(authProvider.currentUser!.id);

      // Load storage facilities owned by this vendor
      await storageProvider.fetchVendorFacilities(authProvider.currentUser!.id);
      setState(() {
        _ownedFacilities = storageProvider.facilities;
        _pendingBookings = storageProvider.pendingBookings;
        _expiringItems = storageProvider.expiringItems;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Inventory', icon: Icon(Icons.inventory)),
            Tab(text: 'Orders', icon: Icon(Icons.shopping_bag)),
            Tab(text: 'Temperature', icon: Icon(Icons.thermostat)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(user?.name ?? 'Vendor'),
              accountEmail: Text(user?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  user?.name.substring(0, 1).toUpperCase() ?? 'V',
                  style: TextStyle(fontSize: 24.0, color: AppConstants.primaryColor),
                ),
              ),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_business),
              title: const Text('Add Product'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to add product screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Analytics'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to analytics screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to settings screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.signOut();
                // Navigation will be handled by a listener
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(authProvider),
                    const SizedBox(height: 16),
                    _buildStatisticsCards(Provider.of<OrderProvider>(context)),
                    const SizedBox(height: 16),
                    _buildColdStorageSection(),
                    const SizedBox(height: 16),
                    _buildPendingBookingsSection(),
                    const SizedBox(height: 16),
                    _buildExpiringItemsSection(),
                  ],
                ),
              ),
            ),
      floatingActionButton: _selectedIndex == 1 
          ? FloatingActionButton(
              onPressed: () {
                // Navigate to add product screen
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    final user = authProvider.currentUser;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user?.name ?? 'Vendor'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your cold storage and track orders with temperature control',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(OrderProvider orderProvider) {
    final pendingOrders = orderProvider.vendorOrders
        .where((order) => order.status == 'pending')
        .length;
    final inTransitOrders = orderProvider.vendorOrders
        .where((order) => order.status == 'in_transit')
        .length;
    final totalOrders = orderProvider.vendorOrders.length;

    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard('Facilities', _ownedFacilities.length.toString(), Colors.blue),
        _buildStatCard('Pending Bookings', _pendingBookings.length.toString(), Colors.orange),
        _buildStatCard('Expiring Items', _expiringItems.length.toString(), Colors.red),
        _buildStatCard('Pending Orders', pendingOrders.toString(), Colors.amber),
        _buildStatCard('In Transit', inTransitOrders.toString(), Colors.purple),
        _buildStatCard('Total Orders', totalOrders.toString(), Colors.teal),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColdStorageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Cold Storage Facilities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add New'),
              onPressed: () {
                // Navigate to add new facility screen
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ownedFacilities.isEmpty
            ? _buildEmptyState('No facilities yet', 'Add your first cold storage facility to start managing temperature-controlled storage.')
            : Column(
                children: _ownedFacilities.map((facility) => _buildFacilityCard(facility)).toList(),
              ),
      ],
    );
  }

  Widget _buildFacilityCard(StorageFacility facility) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Facility image or gradient header
          Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppConstants.primaryColor, AppConstants.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${facility.address.city}, ${facility.address.state}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      facility.compartments.length.toString() + ' compartments',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Compartments overview
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Temperature Zones:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTemperatureZonesRow(facility),
                const SizedBox(height: 12),
                
                // Alert indicators
                const Text(
                  'Alerts:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildAlertsRow(facility),
                const SizedBox(height: 12),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.dashboard),
                        label: const Text('Manage'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FacilityManagementScreen(facilityId: facility.id),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        onPressed: () {
                          // Navigate to edit facility
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            label: Text(zone.displayName),
            backgroundColor: getColorForTemperatureZone(zone).withOpacity(0.1),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAlertsRow(StorageFacility facility) {
    int temperatureAlerts = 0;
    int capacityAlerts = 0;
    int expiryAlerts = 0;
    
    // Count temperature alerts
    for (final compartment in facility.compartments) {
      if (compartment.temperatureStatus == TemperatureStatus.outOfRange) {
        temperatureAlerts++;
      }
      
      // Check capacity (> 90% full)
      if (compartment.capacity > 0 && 
          (compartment.capacity - compartment.availableCapacity) / compartment.capacity > 0.9) {
        capacityAlerts++;
      }
    }
    
    // Count expiry alerts (items expiring in the next 3 days)
    for (final item in _expiringItems) {
      if (item.compartmentId != null && 
          facility.compartments.any((c) => c.id == item.compartmentId)) {
        expiryAlerts++;
      }
    }
    
    return Row(
      children: [
        _buildAlertIndicator(temperatureAlerts, Icons.thermostat, Colors.red, 'Temperature'),
        const SizedBox(width: 16),
        _buildAlertIndicator(capacityAlerts, Icons.inventory_2, Colors.orange, 'Capacity'),
        const SizedBox(width: 16),
        _buildAlertIndicator(expiryAlerts, Icons.schedule, Colors.amber, 'Expiry'),
      ],
    );
  }

  Widget _buildAlertIndicator(int count, IconData icon, Color color, String label) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: count > 0 ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: count > 0 ? color : Colors.grey,
                size: 24,
              ),
            ),
            if (count > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: count > 0 ? color : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Booking Requests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _pendingBookings.isEmpty
            ? _buildEmptyState('No pending bookings', 'All booking requests have been processed.')
            : Column(
                children: _pendingBookings.map((booking) => _buildBookingCard(booking)).toList(),
              ),
      ],
    );
  }

  Widget _buildBookingCard(StorageBooking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(booking.status.displayName),
                  backgroundColor: _getStatusColor(booking.status),
                  labelStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 4),
                Text('User ID: ${booking.userId}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text('${_formatDate(booking.startDate)} - ${_formatDate(booking.endDate)}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.warehouse_outlined, size: 16),
                const SizedBox(width: 4),
                Text('Space: ${booking.totalSpaceRequired.toStringAsFixed(1)} m³'),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, size: 16),
                const SizedBox(width: 4),
                Text('\$${booking.totalAmount.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    child: const Text('Reject'),
                    onPressed: () {
                      // Reject booking
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    child: const Text('Approve'),
                    onPressed: () {
                      // Approve booking
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpiringItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items Expiring Soon',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _expiringItems.isEmpty
            ? _buildEmptyState('No items expiring soon', 'All stored items are within their shelf life.')
            : Column(
                children: _expiringItems.map((item) => _buildExpiringItemCard(item)).toList(),
              ),
      ],
    );
  }

  Widget _buildExpiringItemCard(StoredItem item) {
    final daysUntilExpiry = item.expiryDate.difference(DateTime.now()).inDays;
    final isUrgent = daysUntilExpiry <= 3;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              color: isUrgent ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Expires in $daysUntilExpiry days (${_formatDate(item.expiryDate)})',
                    style: TextStyle(
                      color: isUrgent ? Colors.red : Colors.orange,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Compartment ID: ${item.compartmentId}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '${item.quantity.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.category,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.green;
      case BookingStatus.active:
        return Colors.blue;
      case BookingStatus.completed:
        return Colors.purple;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.expired:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
} 