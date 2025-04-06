import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/compartment.dart';
import '../../providers/compartment_provider.dart';

class AddEditCompartmentScreen extends StatefulWidget {
  final Compartment? compartment;

  const AddEditCompartmentScreen({
    Key? key,
    this.compartment,
  }) : super(key: key);

  @override
  State<AddEditCompartmentScreen> createState() => _AddEditCompartmentScreenState();
}

class _AddEditCompartmentScreenState extends State<AddEditCompartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _capacityController;
  late TextEditingController _minTemperatureController;
  late TextEditingController _maxTemperatureController;
  late TextEditingController _currentTemperatureController;

  TemperatureZone _selectedZone = TemperatureZone.frozen;
  CompartmentStatus _selectedStatus = CompartmentStatus.available;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.compartment?.name ?? '');
    _descriptionController = TextEditingController(text: widget.compartment?.description ?? '');
    _capacityController = TextEditingController(
      text: widget.compartment?.capacity.toString() ?? '',
    );
    _minTemperatureController = TextEditingController(
      text: widget.compartment?.minTemperature.toString() ?? '',
    );
    _maxTemperatureController = TextEditingController(
      text: widget.compartment?.maxTemperature.toString() ?? '',
    );
    _currentTemperatureController = TextEditingController(
      text: widget.compartment?.currentTemperature.toString() ?? '',
    );

    if (widget.compartment != null) {
      _selectedZone = widget.compartment!.temperatureZone;
      _selectedStatus = widget.compartment!.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    _minTemperatureController.dispose();
    _maxTemperatureController.dispose();
    _currentTemperatureController.dispose();
    super.dispose();
  }

  Future<void> _saveCompartment() async {
    if (!_formKey.currentState!.validate()) return;

    final compartment = Compartment(
      id: widget.compartment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      facilityId: widget.compartment?.facilityId ?? 'facility_1', // TODO: Get actual facility ID
      name: _nameController.text,
      description: _descriptionController.text,
      capacity: double.parse(_capacityController.text),
      temperatureZone: _selectedZone,
      minTemperature: double.parse(_minTemperatureController.text),
      maxTemperature: double.parse(_maxTemperatureController.text),
      currentTemperature: double.parse(_currentTemperatureController.text),
      status: _selectedStatus,
      currentOrderId: widget.compartment?.currentOrderId,
      currentCustomerId: widget.compartment?.currentCustomerId,
      lastMaintenanceDate: widget.compartment?.lastMaintenanceDate,
      nextMaintenanceDate: widget.compartment?.nextMaintenanceDate,
      productIds: widget.compartment?.productIds,
      metadata: widget.compartment?.metadata,
    );

    final provider = context.read<CompartmentProvider>();
    final success = widget.compartment == null
        ? await provider.addCompartment(compartment)
        : await provider.updateCompartment(compartment);

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.compartment == null ? 'Add Compartment' : 'Edit Compartment'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(
                labelText: 'Capacity (m³)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter capacity';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TemperatureZone>(
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
                if (value != null) {
                  setState(() {
                    _selectedZone = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minTemperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Min Temperature (°C)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxTemperatureController,
                    decoration: const InputDecoration(
                      labelText: 'Max Temperature (°C)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentTemperatureController,
              decoration: const InputDecoration(
                labelText: 'Current Temperature (°C)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter current temperature';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (widget.compartment == null)
              DropdownButtonFormField<CompartmentStatus>(
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
                  if (value != null) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  }
                },
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveCompartment,
              child: Text(widget.compartment == null ? 'Add Compartment' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
} 