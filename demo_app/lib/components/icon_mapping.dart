// This file will be used by the CourseScreen to render the Material Icons
import 'package:flutter/material.dart';

class IconMapping {
  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'computer_outlined':
        return Icons.computer_outlined;
      case 'business_center':
        return Icons.business_center;
      case 'people_alt_outlined':
        return Icons.people_alt_outlined;
      case 'sailing_outlined':
        return Icons.sailing_outlined;
      case 'train_outlined':
        return Icons.train_outlined;
      case 'precision_manufacturing_outlined':
        return Icons.precision_manufacturing_outlined;
      case 'directions_car_outlined':
        return Icons.directions_car_outlined;
      case 'code_outlined':
        return Icons.code_outlined;
      default:
        return Icons.school; // Default icon
    }
  }

  static Color getColorFromHex(String colorCode) {
    try {
      // If the color code is in format "#RRGGBB"
      if (colorCode.startsWith('#')) {
        return Color(int.parse('0xFF${colorCode.substring(1)}'));
      }
      // If the color code is already in format "0xFFRRGGBB"
      else if (colorCode.startsWith('0x')) {
        return Color(int.parse(colorCode));
      }
      // Default color if parsing fails
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }
}