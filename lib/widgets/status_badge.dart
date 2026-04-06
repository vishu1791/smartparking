import 'package:flutter/material.dart';
import '../models/parking_slot.dart';
import '../utils/constants.dart';

class StatusBadge extends StatelessWidget {
  final SlotStatus status;
  final bool isDark;

  const StatusBadge({Key? key, required this.status, this.isDark = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case SlotStatus.available:
        bgColor = AppConstants.availableLight;
        textColor = AppConstants.availableColor;
        label = "Available";
        break;
      case SlotStatus.occupied:
        bgColor = AppConstants.occupiedLight;
        textColor = AppConstants.occupiedColor;
        label = "Occupied";
        break;
      case SlotStatus.reserved:
        bgColor = AppConstants.reservedLight;
        textColor = AppConstants.reservedColor;
        label = "Reserved";
        break;
    }

    if(isDark) {
      bgColor = textColor.withOpacity(0.2);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
