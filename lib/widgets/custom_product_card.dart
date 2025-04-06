import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/app_constants.dart';
import '../models/product.dart';
import '../utils/temperature_utils.dart';

class CustomProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool compact;
  
  const CustomProductCard({
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
        elevation: compact ? 1 : 2,
        margin: compact ? const EdgeInsets.all(2) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(compact ? 6 : AppConstants.defaultBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with temperature zone indicator
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: compact ? 1.0 : 1.5,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl ?? 'https://placehold.co/400x300/EAEAEA/CCCCCC?text=No+Image',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: SizedBox(
                          width: compact ? 15 : 24,
                          height: compact ? 15 : 24,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.grey,
                        size: compact ? 20 : 24,
                      ),
                    ),
                  ),
                ),
                // Temperature zone indicator
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 4 : 8,
                      vertical: compact ? 2 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: zoneColor,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          zoneIcon,
                          color: Colors.white,
                          size: compact ? 10 : 16,
                        ),
                        SizedBox(width: compact ? 2 : 4),
                        Text(
                          zoneName.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 8 : 12,
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(compact ? 6 : AppConstants.smallPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: compact ? 12 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: compact ? 1 : 4),
                    if (!compact)
                      Expanded(
                        child: Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    // Price display
                    Container(
                      padding: EdgeInsets.symmetric(vertical: compact ? 2 : 4),
                      width: double.infinity,
                      child: Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontSize: compact ? 12 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Add to cart button - Only if space allows
            if (onAddToCart != null && !compact)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  8,
                  0,
                  8,
                  8,
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
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 2),
                child: SizedBox(
                  width: double.infinity,
                  height: 22, // Smaller fixed height button
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          4, // Smaller border radius
                        ),
                      ),
                      padding: EdgeInsets.zero, // Remove padding
                    ),
                    child: const Text('Add', style: TextStyle(fontSize: 10)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 