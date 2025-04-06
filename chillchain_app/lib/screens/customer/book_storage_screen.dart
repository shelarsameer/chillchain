import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../constants/app_constants.dart';
import '../../models/storage.dart';
import '../../models/product.dart';
import '../../models/storage_booking.dart';
import '../../models/user.dart';
import '../../providers/storage_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../utils/temperature_utils.dart';

class BookStorageScreen extends StatefulWidget {
  final StorageFacility facility;
  
  const BookStorageScreen({
    Key? key,
    required this.facility,
  }) : super(key: key);

  @override
  _BookStorageScreenState createState() => _BookStorageScreenState();
}

class _BookStorageScreenState extends State<BookStorageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Booking details
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 8));
  TemperatureZone _selectedZone = TemperatureZone.chilled;
  StorageBookingType _bookingType = StorageBookingType.weekly;
  String? _compartmentId;
  final List<BookingItem> _items = [];
  final TextEditingController _notesController = TextEditingController();
  
  // For adding new items
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _spaceController = TextEditingController();
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 30));
  
  // Calculated values
  double _totalSpace = 0.0;
  double _totalWeight = 0.0;
  double _totalCost = 0.0;
  bool _isCalculating = false;
  
  @override
  void initState() {
    super.initState();
    _selectDefaultCompartment();
  }
  
  @override
  void dispose() {
    _productNameController.dispose();
    _categoryController.dispose();
    _quantityController.dispose();
    _spaceController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  // Select a default compartment based on the selected temperature zone
  void _selectDefaultCompartment() {
    final availableCompartments = widget.facility.compartments.where(
      (comp) => comp.temperatureZone == _selectedZone && 
                comp.isAvailable &&
                comp.availableCapacity > 0
    ).toList();
    
    if (availableCompartments.isNotEmpty) {
      setState(() => _compartmentId = availableCompartments.first.id);
    } else {
      setState(() => _compartmentId = null);
    }
    
    _updateCalculations();
  }
  
  // Calculate total space, weight and cost
  void _updateCalculations() {
    setState(() => _isCalculating = true);
    
    _totalSpace = _items.fold(0.0, (sum, item) => sum + item.spaceRequired);
    _totalWeight = _items.fold(0.0, (sum, item) => sum + item.quantity);
    
    final storageProvider = Provider.of<StorageProvider>(context, listen: false);
    final durationDays = _endDate.difference(_startDate).inDays;
    
    if (durationDays > 0) {
      _totalCost = storageProvider.estimateBookingCost(
        _selectedZone,
        _totalSpace,
        _bookingType,
        durationDays,
      );
    } else {
      _totalCost = 0.0;
    }
    
    setState(() => _isCalculating = false);
  }
  
  // Add a new item to the booking
  void _addItem() {
    if (_productNameController.text.isEmpty || 
        _categoryController.text.isEmpty || 
        _quantityController.text.isEmpty ||
        _spaceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;
    final space = double.tryParse(_spaceController.text) ?? 0.0;
    
    if (quantity <= 0 || space <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity and space must be greater than zero')),
      );
      return;
    }
    
    // Create a new booking item
    final item = BookingItem(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      productId: 'new_product',
      productName: _productNameController.text,
      category: _categoryController.text,
      quantity: quantity,
      temperatureZone: _selectedZone,
      expiryDate: _expiryDate,
      spaceRequired: space,
    );
    
    setState(() {
      _items.add(item);
      _productNameController.clear();
      _categoryController.clear();
      _quantityController.clear();
      _spaceController.clear();
    });
    
    _updateCalculations();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added to booking'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // Remove an item from the booking
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _updateCalculations();
    });
  }
  
  // Submit the booking
  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }
    
    final storageProvider = Provider.of<StorageProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to make a booking')),
      );
      return;
    }
    
    try {
      // Create a new booking
      final booking = StorageBooking(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        userId: authProvider.currentUser!.id,
        facilityId: widget.facility.id,
        compartmentId: _compartmentId,
        requestDate: DateTime.now(),
        startDate: _startDate,
        endDate: _endDate,
        items: _items,
        bookingType: _bookingType,
        status: BookingStatus.pending,
        totalAmount: _totalCost,
        notes: _notesController.text,
      );
      
      // Submit the booking
      final result = await storageProvider.createBooking(booking);
      
      if (result != null) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${storageProvider.error ?? "Unknown error"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Show date picker for start date
  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        
        // Ensure end date is after start date
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
        
        _updateCalculations();
      });
    }
  }
  
  // Show date picker for end date
  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _updateCalculations();
      });
    }
  }
  
  // Show date picker for expiry date
  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (picked != null && picked != _expiryDate) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Get available compartments for the selected temperature zone
    final availableCompartments = widget.facility.compartments.where(
      (comp) => comp.temperatureZone == _selectedZone && 
                comp.isAvailable &&
                comp.availableCapacity > 0
    ).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Storage'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Facility info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.facility.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.facility.address.fullAddress,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Booking details
            const Text(
              'Booking Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Temperature zone
            DropdownButtonFormField<TemperatureZone>(
              value: _selectedZone,
              decoration: const InputDecoration(
                labelText: 'Temperature Zone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.thermostat),
              ),
              items: TemperatureZone.values.map((zone) {
                return DropdownMenuItem(
                  value: zone,
                  child: Text(zone.toString().split('.').last),
                );
              }).toList(),
              onChanged: (zone) {
                if (zone != null) {
                  setState(() {
                    _selectedZone = zone;
                    _compartmentId = null;
                  });
                  _selectDefaultCompartment();
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Compartment
            DropdownButtonFormField<String>(
              value: _compartmentId,
              decoration: const InputDecoration(
                labelText: 'Storage Compartment',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.storage),
              ),
              items: availableCompartments.map((compartment) {
                return DropdownMenuItem(
                  value: compartment.id,
                  child: Text('${compartment.name} (${compartment.availableCapacity.toStringAsFixed(1)} m³ available)'),
                );
              }).toList(),
              onChanged: (id) {
                if (id != null) {
                  setState(() => _compartmentId = id);
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a compartment';
                }
                return null;
              },
            ),
            
            if (availableCompartments.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'No compartments available for this temperature zone',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Booking type
            DropdownButtonFormField<StorageBookingType>(
              value: _bookingType,
              decoration: const InputDecoration(
                labelText: 'Booking Type',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.timer),
              ),
              items: StorageBookingType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (type) {
                if (type != null) {
                  setState(() {
                    _bookingType = type;
                    _updateCalculations();
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Date range
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectStartDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: DateFormat('MMM dd, yyyy').format(_startDate),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectEndDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: DateFormat('MMM dd, yyyy').format(_endDate),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Duration: ${_endDate.difference(_startDate).inDays} days',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 16),
            
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            // Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Items to Store',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddItemDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No items added yet. Use the Add Item button to add products you want to store.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text('Category: ${item.category}'),
                                Text('Quantity: ${item.quantity.toStringAsFixed(1)} kg'),
                                Text('Space Required: ${item.spaceRequired.toStringAsFixed(1)} m³'),
                                Text('Expiry: ${DateFormat('MMM dd, yyyy').format(item.expiryDate)}'),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 24),
            
            // Summary
            Card(
              color: AppConstants.primaryColor.withOpacity(0.05),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow('Total Items', '${_items.length}'),
                    _buildSummaryRow('Total Weight', '${_totalWeight.toStringAsFixed(1)} kg'),
                    _buildSummaryRow('Total Space', '${_totalSpace.toStringAsFixed(1)} m³'),
                    _buildSummaryRow(
                      'Booking Duration', 
                      '${_endDate.difference(_startDate).inDays} days'
                    ),
                    const Divider(),
                    _buildSummaryRow(
                      'Estimated Cost', 
                      '\$${_totalCost.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Submit button
            ElevatedButton(
              onPressed: _items.isEmpty || _isCalculating ? null : _submitBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isCalculating
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text(
                      'Submit Booking Request',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // Terms and conditions
            const Text(
              'By submitting this booking, you agree to our terms and conditions regarding cold storage services.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  // Show dialog to add a new item
  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Storage Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _productNameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity (kg)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _spaceController,
                      decoration: const InputDecoration(
                        labelText: 'Space Required (m³)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Expiry Date: '),
                        TextButton(
                          onPressed: () => _selectExpiryDate(context),
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(_expiryDate),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _addItem();
                  },
                  child: const Text('Add Item'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Build a summary row with label and value
  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
} 