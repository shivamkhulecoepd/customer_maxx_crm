import 'package:flutter/material.dart';

class ModernStatsCard extends StatelessWidget {
  final String value;
  final String title;
  final IconData icon;
  final Color color;

  const ModernStatsCard({
    super.key,
    required this.value,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final double cardWidth = size.width * 0.42; // Responsive width
    final double iconSize = size.width * 0.07; // Responsive icon
    final double valueFont = size.width * 0.06; // Responsive value font
    final double titleFont = size.width * 0.04; // Responsive title font

    return LayoutBuilder(
      builder: (context, constraints) {
        return Expanded(
          child: Container(
            width: cardWidth,
            constraints: const BoxConstraints(minWidth: 140, maxWidth: 220),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withValues(alpha: 0.2) // Fixed deprecated withOpacity
                      : Colors.grey.withValues(alpha: 0.1), // Fixed deprecated withOpacity
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(size.width * 0.02),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1), // Fixed deprecated withOpacity
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: valueFont,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFont,
                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}