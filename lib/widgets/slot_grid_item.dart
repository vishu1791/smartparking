import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/parking_slot.dart';
import '../providers/theme_provider.dart';
import '../providers/parking_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class SlotGridItem extends StatelessWidget {
  final ParkingSlot slot;
  final VoidCallback onTap;

  const SlotGridItem({
    Key? key,
    required this.slot,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final remainingTime = Provider.of<ParkingProvider>(context).getRemainingReservationSeconds(slot.id);

    LinearGradient getGradient() {
      switch (slot.status) {
        case SlotStatus.available:
          return AppConstants.availableGradient;
        case SlotStatus.occupied:
          return AppConstants.occupiedGradient;
        case SlotStatus.reserved:
          return AppConstants.reservedGradient;
      }
    }

    Color getShadowColor() {
       switch (slot.status) {
        case SlotStatus.available:
          return AppConstants.availableColor;
        case SlotStatus.occupied:
          return AppConstants.occupiedColor;
        case SlotStatus.reserved:
          return AppConstants.reservedColor;
      }
    }

    return Hero(
      tag: 'slot_card_${slot.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: isDark ? null : getGradient(),
              color: isDark ? getShadowColor().withOpacity(0.12) : null,
              borderRadius: BorderRadius.circular(20),
              border: isDark ? Border.all(color: getShadowColor(), width: 2) : null,
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: getShadowColor().withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // Hug content
                children: [
                  Flexible(
                    flex: 3,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.transparent : Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          slot.status == SlotStatus.reserved ? Icons.lock_clock : Icons.directions_car_rounded,
                          color: isDark ? getShadowColor() : Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        slot.id,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark ? getShadowColor() : Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    flex: 2,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? getShadowColor().withOpacity(0.2) : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          slot.status == SlotStatus.reserved 
                              ? Formatters.formatDuration(remainingTime)
                              : slot.status.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppConstants.textDark : getShadowColor(),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
