import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/parking_slot.dart';
import '../providers/parking_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/custom_button.dart';
import '../widgets/status_badge.dart';
import 'billing_screen.dart';

class SlotDetailScreen extends StatelessWidget {
  final String slotId;

  const SlotDetailScreen({Key? key, required this.slotId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Consumer<ParkingProvider>(
      builder: (context, provider, child) {
        final slot = provider.getSlotById(slotId);
        final isOccupied = slot.status == SlotStatus.occupied;
        final currentDuration = provider.getCurrentDurationInSeconds(slotId);
        final remainingReservation = provider.getRemainingReservationSeconds(slotId);

        return Scaffold(
          backgroundColor: isDark ? AppConstants.backgroundDark : AppConstants.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDark ? AppConstants.textDark : AppConstants.textLight,
            ),
            title: Text(
              'Slot Details',
              style: TextStyle(
                color: isDark ? AppConstants.textDark : AppConstants.textLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildMainCard(slot, isDark, isOccupied, currentDuration, remainingReservation),
                const SizedBox(height: 40),
                _buildActionButtons(context, slot, provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainCard(ParkingSlot slot, bool isDark, bool isOccupied, int currentDuration, int remainingReservation) {
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? AppConstants.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: isDark ? [] : AppConstants.mediumShadow,
            border: isDark ? Border.all(color: getShadowColor().withOpacity(0.3), width: 2) : null,
          ),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: getGradient(),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: getShadowColor().withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: Center(
                  child: Icon(
                    slot.status == SlotStatus.reserved ? Icons.lock_clock : Icons.time_to_leave, 
                    color: Colors.white, 
                    size: 50
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                slot.id,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppConstants.textDark : AppConstants.textLight,
                ),
              ),
              const SizedBox(height: 16),
              StatusBadge(status: slot.status, isDark: isDark),
              const SizedBox(height: 32),
              if (slot.startTime != null && !isOccupied)
                _buildInfoRow('Started', Formatters.formatTime(slot.startTime!), isDark),
              if (isOccupied) ...[
                const Divider(),
                const SizedBox(height: 24),
                Text(
                  'PARKING DURATION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppConstants.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.formatDuration(currentDuration),
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    color: isDark ? AppConstants.textDark : AppConstants.textLight,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
              if (slot.status == SlotStatus.reserved) ...[
                const Divider(),
                const SizedBox(height: 24),
                Text(
                  'RESERVATION EXPIRES IN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppConstants.textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.formatDuration(remainingReservation),
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w300,
                    color: AppConstants.reservedColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: AppConstants.textMuted),
        ),
        Text(
           value,
           style: TextStyle(
             fontSize: 16,
             fontWeight: FontWeight.w600,
             color: isDark ? AppConstants.textDark : AppConstants.textLight,
           ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, ParkingSlot slot, ParkingProvider provider) {
    return Column(
      children: [
        if (slot.status == SlotStatus.available)
          CustomButton(
            text: 'Reserve Slot',
            icon: Icons.bookmark_border,
            gradient: AppConstants.reservedGradient,
            onPressed: () => provider.reserveSlot(slot.id),
          ),
        if (slot.status == SlotStatus.available || slot.status == SlotStatus.reserved) ...[
          const SizedBox(height: 16),
          CustomButton(
            text: 'Start Parking',
            icon: Icons.play_arrow_rounded,
            gradient: AppConstants.occupiedGradient,
            onPressed: () => provider.startParking(slot.id),
          ),
        ],
        if (slot.status == SlotStatus.occupied)
          CustomButton(
            text: 'End Parking',
            icon: Icons.stop_rounded,
            gradient: AppConstants.primaryGradient,
            onPressed: () {
              final session = provider.endParking(slot.id);
              if (session != null) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        BillingScreen(session: session),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      return SlideTransition(position: animation.drive(tween), child: child);
                    },
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}
