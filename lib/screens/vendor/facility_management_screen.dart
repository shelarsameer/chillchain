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
import '../../providers/temperature_provider.dart';
import '../../utils/date_time_utils.dart';

class FacilityManagementScreen extends StatefulWidget {
  const FacilityManagementScreen({Key? key}) : super(key: key);

  @override
  State<FacilityManagementScreen> createState() => _FacilityManagementScreenState();
}

class _FacilityManagementScreenState extends State<FacilityManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _selectedFacilityId;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFacilityData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadFacilityData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load facility data if needed
      final temperatureProvider = Provider.of<TemperatureProvider>(context, listen: false);
      
      if (temperatureProvider.facilityStats.isNotEmpty && _selectedFacilityId == null) {
        // Select the first facility by default
        setState(() {
          _selectedFacilityId = temperatureProvider.facilityStats.keys.first;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading facility data: ${e.toString()}'),
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
        title: const Text('Facility Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Storage Status'),
            Tab(text: 'Temperature Logs'),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildStorageStatusTab(),
              _buildTemperatureLogsTab(),
            ],
          ),
    );
  }
  
  Widget _buildStorageStatusTab() {
    final temperatureProvider = Provider.of<TemperatureProvider>(context);
    final facilityStats = temperatureProvider.facilityStats;
    
    if (facilityStats.isEmpty) {
      return const Center(
        child: Text('No facilities found'),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFacilitySelector(facilityStats.keys.toList()),
          const SizedBox(height: 16),
          if (_selectedFacilityId != null) ...[
            _buildFacilityOverview(facilityStats[_selectedFacilityId!]!),
            const SizedBox(height: 16),
            _buildStorageZonesSection(facilityStats[_selectedFacilityId!]!),
            const SizedBox(height: 16),
            _buildActiveAlertsSection(facilityStats[_selectedFacilityId!]!),
          ],
        ],
      ),
    );
  }
  
  Widget _buildFacilitySelector(List<String> facilityIds) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Facility',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedFacilityId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: facilityIds.map((facilityId) {
                final facilityName = Provider.of<TemperatureProvider>(context)
                    .facilityStats[facilityId]!.name;
                return DropdownMenuItem<String>(
                  value: facilityId,
                  child: Text(facilityName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFacilityId = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFacilityOverview(FacilityStats stats) {
    final temperatureProvider = Provider.of<TemperatureProvider>(context);
    final hasActiveAlerts = stats.activeAlerts.isNotEmpty;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stats.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasActiveAlerts ? Colors.red.shade100 : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasActiveAlerts ? Icons.warning_amber_rounded : Icons.check_circle,
                        size: 16,
                        color: hasActiveAlerts ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasActiveAlerts ? 'Alert' : 'Normal',
                        style: TextStyle(
                          color: hasActiveAlerts ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Overall Capacity Usage',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: TemperatureZone.values.map((zone) {
                final usage = temperatureProvider.getCapacityUsage(stats.facilityId, zone);
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        zone.toString().split('.').last,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      CircularProgressIndicator(
                        value: usage,
                        backgroundColor: Colors.grey.shade200,
                        color: _getColorForZone(zone),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(usage * 100).toInt()}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStorageZonesSection(FacilityStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Storage Zones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...TemperatureZone.values.map((zone) => _buildStorageZoneCard(stats, zone)),
      ],
    );
  }
  
  Widget _buildStorageZoneCard(FacilityStats stats, TemperatureZone zone) {
    final temperatureProvider = Provider.of<TemperatureProvider>(context);
    final currentTemp = temperatureProvider.getCurrentTemperature(stats.facilityId, zone);
    final usage = temperatureProvider.getCapacityUsage(stats.facilityId, zone);
    
    // Get temperature range for the zone
    final expectedRange = _getExpectedRangeForZone(zone);
    final isTemperatureNormal = currentTemp != null && 
        currentTemp >= expectedRange.min && 
        currentTemp <= expectedRange.max;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _getColorForZone(zone),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${zone.toString().split('.').last} Zone',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (currentTemp != null)
                  Row(
                    children: [
                      Icon(
                        isTemperatureNormal ? Icons.check_circle : Icons.warning,
                        color: isTemperatureNormal ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${currentTemp.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          color: isTemperatureNormal ? Colors.black : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Capacity Usage',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: usage,
                        backgroundColor: Colors.grey.shade200,
                        color: _getColorForUsage(usage),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(usage * 100).toInt()}% Used',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Temperature Range',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${expectedRange.min.toStringAsFixed(1)}°C to ${expectedRange.max.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActiveAlertsSection(FacilityStats stats) {
    final activeAlerts = stats.activeAlerts;
    
    if (activeAlerts.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Active Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'No active alerts',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Active Alerts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${activeAlerts.length}',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...activeAlerts.map((alert) {
              final temperatureLog = alert.log;
              final zone = temperatureLog.zone;
              final expectedRange = _getExpectedRangeForZone(zone);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.red.shade50,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Temperature out of range in ${zone.toString().split('.').last} Zone',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Temperature',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${temperatureLog.temperature.toStringAsFixed(1)}°C',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Expected Range',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  '${expectedRange.min.toStringAsFixed(1)}°C to ${expectedRange.max.toStringAsFixed(1)}°C',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Detected At',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  DateTimeUtils.formatDateTime(alert.detectedAt),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () => _acknowledgeAlert(alert),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('Acknowledge'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTemperatureLogsTab() {
    if (_selectedFacilityId == null) {
      return const Center(
        child: Text('Please select a facility in the Storage Status tab'),
      );
    }
    
    final temperatureProvider = Provider.of<TemperatureProvider>(context);
    final zones = TemperatureZone.values;
    
    return DefaultTabController(
      length: zones.length,
      child: Column(
        children: [
          const SizedBox(height: 8),
          TabBar(
            isScrollable: true,
            tabs: zones.map((zone) {
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getColorForZone(zone),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      zone.toString().split('.').last,
                      style: TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: TabBarView(
              children: zones.map((zone) {
                final logs = temperatureProvider.getLogsForFacilityAndZone(
                  _selectedFacilityId!,
                  zone,
                );
                
                if (logs.isEmpty) {
                  return const Center(
                    child: Text('No temperature logs found for this zone'),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final expectedRange = _getExpectedRangeForZone(zone);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: log.isWithinThreshold ? Colors.white : Colors.red.shade50,
                      child: ListTile(
                        leading: Icon(
                          log.isWithinThreshold ? Icons.check_circle : Icons.warning,
                          color: log.isWithinThreshold ? Colors.green : Colors.red,
                        ),
                        title: Row(
                          children: [
                            Text(
                              '${log.temperature.toStringAsFixed(1)}°C',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: log.isWithinThreshold ? Colors.black : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${expectedRange.min.toStringAsFixed(1)}°C - ${expectedRange.max.toStringAsFixed(1)}°C)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          DateTimeUtils.formatDateTime(log.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        trailing: Text(
                          'Device ${log.deviceId.split('-').last}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  void _acknowledgeAlert(TemperatureAlert alert) {
    showDialog(
      context: context,
      builder: (context) {
        final notesController = TextEditingController();
        return AlertDialog(
          title: const Text('Acknowledge Alert'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Temperature out of range in ${alert.log.zone.toString().split('.').last} Zone',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
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
                Navigator.pop(context);
                final temperatureProvider = Provider.of<TemperatureProvider>(context, listen: false);
                temperatureProvider.acknowledgeAlert(
                  alert.id,
                  'current-user-id', // In a real app, get this from auth provider
                  notesController.text.isNotEmpty ? notesController.text : null,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
              ),
              child: const Text('Acknowledge'),
            ),
          ],
        );
      },
    );
  }
  
  Color _getColorForZone(TemperatureZone zone) {
    switch (zone) {
      case TemperatureZone.frozen:
        return Colors.blue;
      case TemperatureZone.chilled:
        return Colors.teal;
      case TemperatureZone.cool:
        return Colors.green;
      case TemperatureZone.ambient:
        return Colors.amber;
    }
  }
  
  Color _getColorForUsage(double usage) {
    if (usage < 0.7) {
      return Colors.green;
    } else if (usage < 0.9) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  ({double min, double max}) _getExpectedRangeForZone(TemperatureZone zone) {
    switch (zone) {
      case TemperatureZone.frozen:
        return (min: -25.0, max: -18.0);
      case TemperatureZone.chilled:
        return (min: 0.0, max: 4.0);
      case TemperatureZone.cool:
        return (min: 4.0, max: 10.0);
      case TemperatureZone.ambient:
        return (min: 15.0, max: 25.0);
    }
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