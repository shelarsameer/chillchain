import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/temperature_utils.dart';
import '../../utils/validators.dart';

class ImageSource {
  static const gallery = ImageSource('gallery');
  static const camera = ImageSource('camera');
  
  final String name;
  const ImageSource(this.name);
}

class XFile {
  final String path;
  XFile(this.path);
}

class ImagePicker {
  Future<XFile?> pickImage({required ImageSource source}) async {
    // This is just a stub for compilation - in real app would use the actual package
    return null;
  }
}

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  
  const AddEditProductScreen({
    Key? key,
    this.product,
  }) : super(key: key);

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _weightController = TextEditingController();
  final _minTempController = TextEditingController();
  final _maxTempController = TextEditingController();
  
  String _selectedCategory = AppConstants.productCategories.first;
  TemperatureZone _selectedZone = TemperatureZone.chilled;
  DateTime _selectedExpiryDate = DateTime.now().add(const Duration(days: 30));
  
  bool _isLoading = false;
  String? _errorMessage;
  XFile? _imageFile;
  bool _isEditing = false;
  
  @override
  void initState() {
    super.initState();
    _isEditing = widget.product != null;
    
    if (widget.product != null) {
      // Edit mode - populate fields with existing data
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _stockController.text = widget.product!.stockQuantity.toString();
      _imageUrlController.text = widget.product!.imageUrl ?? '';
      _selectedCategory = widget.product!.category;
      _selectedZone = widget.product!.temperatureRequirement.zone;
      _minTempController.text = widget.product!.temperatureRequirement.minTemperature.toString();
      _maxTempController.text = widget.product!.temperatureRequirement.maxTemperature.toString();
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    _weightController.dispose();
    _minTempController.dispose();
    _maxTempController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }
  
  void _updateTemperatureRange(TemperatureZone zone) {
    setState(() {
      _selectedZone = zone;
      // Set default temperature ranges based on zone
      switch (zone) {
        case TemperatureZone.frozen:
          _minTempController.text = '-25.0';
          _maxTempController.text = '-18.0';
          break;
        case TemperatureZone.chilled:
          _minTempController.text = '0.0';
          _maxTempController.text = '4.0';
          break;
        case TemperatureZone.cool:
          _minTempController.text = '4.0';
          _maxTempController.text = '10.0';
          break;
        case TemperatureZone.ambient:
          _minTempController.text = '15.0';
          _maxTempController.text = '25.0';
          break;
      }
    });
  }
  
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (!_isEditing && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a product image')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      final product = Product(
        id: widget.product?.id ?? '', // Will be assigned by the service if new
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        imageUrl: widget.product?.imageUrl, // Keep existing URL if editing
        category: _selectedCategory,
        temperatureRequirement: TemperatureRequirement(
          minTemperature: double.tryParse(_minTempController.text) ?? 0.0,
          maxTemperature: double.tryParse(_maxTempController.text) ?? 8.0,
          zone: _selectedZone,
        ),
        stockQuantity: int.tryParse(_stockController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        expiryDate: _selectedExpiryDate,
        vendorId: authProvider.currentUser?.id ?? 'demo-vendor',
      );
      
      if (widget.product == null) {
        // Add new product
        await productProvider.addProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully')),
        );
      } else {
        // Update existing product
        await productProvider.updateProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
        );
      }
      
      Navigator.pop(context, true); // Return success
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving product: ${e.toString()}';
      });
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
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProduct,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    
                    _buildImagePicker(),
                    const SizedBox(height: 16.0),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'Enter product name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Enter product description',
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
                    const SizedBox(height: 16.0),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              hintText: 'Enter price',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a price';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(
                              labelText: 'Stock Quantity',
                              hintText: 'Enter quantity',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter stock quantity';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Image URL (Optional)',
                        hintText: 'Enter image URL',
                        border: OutlineInputBorder(),
                        helperText: 'Leave empty for a default image',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.productCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24.0),
                    
                    const Text(
                      'Temperature Requirements',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    
                    DropdownButtonFormField<TemperatureZone>(
                      value: _selectedZone,
                      decoration: const InputDecoration(
                        labelText: 'Temperature Zone',
                        border: OutlineInputBorder(),
                      ),
                      items: TemperatureZone.values.map((zone) {
                        final zoneName = zone.toString().split('.').last;
                        final zoneInfo = AppConstants.temperatureZones[zoneName.toLowerCase()];
                        return DropdownMenuItem<TemperatureZone>(
                          value: zone,
                          child: Row(
                            children: [
                              Icon(
                                zoneInfo?['icon'] as IconData? ?? Icons.thermostat,
                                color: zoneInfo?['color'] as Color? ?? Colors.blue,
                              ),
                              const SizedBox(width: 8.0),
                              Text(zoneName),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedZone = value;
                            _updateTemperatureRange(value);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16.0),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minTempController,
                            decoration: const InputDecoration(
                              labelText: 'Min Temperature (°C)',
                              border: OutlineInputBorder(),
                              suffixText: '°C',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: TextFormField(
                            controller: _maxTempController,
                            decoration: const InputDecoration(
                              labelText: 'Max Temperature (°C)',
                              border: OutlineInputBorder(),
                              suffixText: '°C',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          widget.product == null ? 'Add Product' : 'Update Product',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.cover,
                  ),
                )
              : widget.product != null && widget.product!.imageUrl != null && widget.product!.imageUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.product!.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Add Product Image',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
} 