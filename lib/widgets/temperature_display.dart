import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/product.dart';
import '../utils/temperature_utils.dart';

class TemperatureDisplay extends StatelessWidget {
  final double temperature;
  final TemperatureRequirement? requirement;
  final bool showDetails;
  final bool showIcon;
  final bool showStatus;
  
  // Individual temperature parameters
  final double? minTemperature;
  final double? maxTemperature;
  final String? unit;
  final TemperatureZone? zone;
  
  // Primary constructor with requirement object
  const TemperatureDisplay({
    Key? key,
    required this.temperature,
    required this.requirement,
    this.showDetails = true,
    this.showIcon = true,
    this.showStatus = true,
    this.minTemperature = null,
    this.maxTemperature = null,
    this.unit = null,
    this.zone = null,
  }) : super(key: key);
  
  // Alternative constructor with individual parameters
  const TemperatureDisplay.simple({
    Key? key,
    required this.temperature,
    required this.minTemperature,
    required this.maxTemperature,
    this.unit = '°C',
    this.zone = TemperatureZone.chilled,
    this.showDetails = true,
    this.showIcon = true,
    this.showStatus = true,
  }) : requirement = null,
       super(key: key);
  
  // Computed properties to handle both constructors
  double get effectiveMinTemperature => minTemperature ?? requirement?.minTemperature ?? 0.0;
  double get effectiveMaxTemperature => maxTemperature ?? requirement?.maxTemperature ?? 0.0;
  String get effectiveUnit => unit ?? '°C';
  TemperatureZone get effectiveZone => zone ?? requirement?.zone ?? TemperatureZone.ambient;
  
  // Create a TemperatureRequirement object from the provided parameters
  TemperatureRequirement get effectiveRequirement => 
    requirement ?? TemperatureRequirement(
      minTemperature: effectiveMinTemperature,
      maxTemperature: effectiveMaxTemperature,
      zone: effectiveZone,
    );
  
  @override
  Widget build(BuildContext context) {
    final isWithinRange = TemperatureUtils.isTemperatureInRange(temperature, effectiveRequirement);
    final statusColor = TemperatureUtils.getTemperatureStatusColor(temperature, effectiveRequirement);
    final zoneName = effectiveZone.toString().split('.').last;
    final zoneColor = TemperatureUtils.getTemperatureZoneColor(zoneName);
    final zoneIcon = TemperatureUtils.getTemperatureZoneIcon(zoneName);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (showIcon) ...[
              Icon(
                zoneIcon,
                color: zoneColor,
                size: 20,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              TemperatureUtils.formatTemperature(temperature),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isWithinRange ? Colors.black87 : statusColor,
              ),
            ),
          ],
        ),
        if (showStatus) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor),
            ),
            child: Text(
              isWithinRange ? 'Optimal' : 'Attention Needed',
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        if (showDetails) ...[
          const SizedBox(height: 4),
          Text(
            'Range: ${TemperatureUtils.formatTemperature(effectiveMinTemperature)} to ${TemperatureUtils.formatTemperature(effectiveMaxTemperature)}',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
        ],
      ],
    );
  }
}

class TemperatureHistoryChart extends StatelessWidget {
  final List<double> temperatures;
  final TemperatureRequirement requirement;
  final List<DateTime>? timestamps;
  
  const TemperatureHistoryChart({
    Key? key,
    required this.temperatures,
    required this.requirement,
    this.timestamps,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final maxTemp = requirement.maxTemperature + 2;
    final minTemp = requirement.minTemperature - 2;
    final range = maxTemp - minTemp;
    
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temperature History',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${maxTemp.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '${requirement.maxTemperature.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppConstants.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${requirement.minTemperature.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppConstants.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${minTemp.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                // Chart
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
                    child: Container(
                      color: Colors.grey.shade100,
                      child: CustomPaint(
                        painter: TemperatureChartPainter(
                          temperatures: temperatures,
                          requirement: requirement,
                          minY: minTemp,
                          maxY: maxTemp,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (timestamps != null && timestamps!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(timestamps!.first),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
                Text(
                  _formatTime(timestamps!.last),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class TemperatureChartPainter extends CustomPainter {
  final List<double> temperatures;
  final TemperatureRequirement requirement;
  final double minY;
  final double maxY;
  
  TemperatureChartPainter({
    required this.temperatures,
    required this.requirement,
    required this.minY,
    required this.maxY,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    if (temperatures.isEmpty) return;
    
    final height = size.height;
    final width = size.width;
    
    // Draw safe range background
    final safeRangePaint = Paint()
      ..color = AppConstants.successColor.withOpacity(0.1);
    
    final safeRangeTop = height - (requirement.maxTemperature - minY) / (maxY - minY) * height;
    final safeRangeBottom = height - (requirement.minTemperature - minY) / (maxY - minY) * height;
    
    canvas.drawRect(
      Rect.fromLTRB(0, safeRangeTop, width, safeRangeBottom),
      safeRangePaint,
    );
    
    // Draw safe range borders
    final safeRangeBorderPaint = Paint()
      ..color = AppConstants.warningColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    canvas.drawLine(
      Offset(0, safeRangeTop),
      Offset(width, safeRangeTop),
      safeRangeBorderPaint,
    );
    
    canvas.drawLine(
      Offset(0, safeRangeBottom),
      Offset(width, safeRangeBottom),
      safeRangeBorderPaint,
    );
    
    // Draw temperature line
    final linePaint = Paint()
      ..color = AppConstants.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final path = Path();
    
    for (int i = 0; i < temperatures.length; i++) {
      final x = i / (temperatures.length - 1) * width;
      final normalizedY = (temperatures[i] - minY) / (maxY - minY);
      final y = height - normalizedY * height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, linePaint);
    
    // Draw points
    final pointPaint = Paint()
      ..color = AppConstants.primaryColor;
    
    for (int i = 0; i < temperatures.length; i++) {
      final x = i / (temperatures.length - 1) * width;
      final normalizedY = (temperatures[i] - minY) / (maxY - minY);
      final y = height - normalizedY * height;
      
      // Determine if temperature is in range
      final isInRange = TemperatureUtils.isTemperatureInRange(
        temperatures[i],
        requirement,
      );
      
      final pointColor = isInRange 
          ? AppConstants.primaryColor 
          : AppConstants.errorColor;
      
      pointPaint.color = pointColor;
      
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
} 