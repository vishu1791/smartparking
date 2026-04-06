import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/parking_session.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/custom_button.dart';

class BillingScreen extends StatelessWidget {
  final ParkingSession session;

  const BillingScreen({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.backgroundDark : AppConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent simple back navigation
        title: Text(
          'Receipt',
          style: TextStyle(
            color: isDark ? AppConstants.textDark : AppConstants.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isDark ? [] : AppConstants.mediumShadow,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppConstants.availableColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: AppConstants.availableColor,
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Payment Successful',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppConstants.textDark : AppConstants.textLight,
                          ),
                        ),
                        const SizedBox(height: 40),
                        _buildReceiptRow('Slot ID', session.slotId, isDark),
                        const SizedBox(height: 16),
                        _buildReceiptRow('Start Time', Formatters.formatTime(session.startTime), isDark),
                        const SizedBox(height: 16),
                        _buildReceiptRow('End Time', Formatters.formatTime(session.endTime), isDark),
                        const SizedBox(height: 16),
                        _buildReceiptRow('Duration', Formatters.formatDuration(session.durationInSeconds), isDark),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Divider(thickness: 1, color: Colors.grey),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Cost',
                              style: TextStyle(
                                fontSize: 18,
                                color: AppConstants.textMuted,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(session.totalCost),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppConstants.textLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Done',
                icon: Icons.home_rounded,
                gradient: AppConstants.primaryGradient,
                onPressed: () {
                  Navigator.pop(context); // Return to Home
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark) {
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
}
