import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_constants.dart';
import '../models/product.dart';
import '../utils/temperature_utils.dart';
import 'temperature_display.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool compact;
  
  const ProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.compact = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final zoneName = product.temperatureRequirement.zone.toString().split('.').last;
    final zoneColor = TemperatureUtils.getTemperatureZoneColor(zoneName);
    final zoneIcon = TemperatureUtils.getTemperatureZoneIcon(zoneName);
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with temperature zone indicator
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.defaultBorderRadius),
                    topRight: Radius.circular(AppConstants.defaultBorderRadius),
                  ),
                  child: AspectRatio(
                    aspectRatio: compact ? 1.2 : 1.5,
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl ?? 'https://placehold.co/400x300/EAEAEA/CCCCCC?text=No+Image',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                // Temperature zone indicator
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: zoneColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppConstants.defaultBorderRadius),
                        bottomRight: Radius.circular(AppConstants.smallBorderRadius),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          zoneIcon,
                          color: Colors.white,
                          size: compact ? 12 : 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          zoneName.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 10 : 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Product details
            Padding(
              padding: EdgeInsets.all(compact ? 8 : AppConstants.smallPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: compact ? 2 : 4),
                  if (!compact)
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: compact ? 4 : 8),
                  // Price display
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    width: double.infinity,
                    child: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontSize: compact ? 14 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Add to cart button
            if (onAddToCart != null && !compact)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.smallPadding,
                  0,
                  AppConstants.smallPadding,
                  AppConstants.smallPadding,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.smallBorderRadius,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ),
              ),
            // Simplified add to cart for compact view
            if (onAddToCart != null && compact)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAddToCart,
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.smallBorderRadius,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProductListItem extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  
  const ProductListItem({
    Key? key,
    required this.product,
    this.onTap,
    this.onAddToCart,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final zoneName = product.temperatureRequirement.zone.toString().split('.').last;
    final zoneColor = TemperatureUtils.getTemperatureZoneColor(zoneName);
    final zoneIcon = TemperatureUtils.getTemperatureZoneIcon(zoneName);
    final simulatedTemp = TemperatureUtils.getSimulatedTemperature(
      product.temperatureRequirement,
      maintainRange: true,
    );
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: AppConstants.smallPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          child: Row(
            children: [
              // Product image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl ?? 'https://placehold.co/400x300/EAEAEA/CCCCCC?text=No+Image',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Temperature zone and expiry info
                    Row(
                      children: [
                        // Temperature zone
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: zoneColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: zoneColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                zoneIcon,
                                size: 12,
                                color: zoneColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${simulatedTemp.toStringAsFixed(1)}°C',
                                style: TextStyle(
                                  color: zoneColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Expiry info
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Expires: ${_formatExpiryDate(product.expiryDate)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Add to cart button
              if (onAddToCart != null) ...[
                const SizedBox(width: AppConstants.smallPadding),
                IconButton(
                  onPressed: onAddToCart,
                  icon: const Icon(Icons.add_shopping_cart),
                  color: AppConstants.primaryColor,
                  tooltip: 'Add to cart',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatExpiryDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 