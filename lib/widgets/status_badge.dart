import 'package:flutter/material.dart';
import 'package:customer_maxx_crm/utils/theme_utils.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double? fontSize;
  final EdgeInsets? padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppThemes.getStatusColor(status);
    
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}