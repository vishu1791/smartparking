import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/parking_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.backgroundDark : AppConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppConstants.textDark : AppConstants.textLight,
        ),
        title: Text(
          'Parking History',
          style: TextStyle(
            color: isDark ? AppConstants.textDark : AppConstants.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ParkingProvider>(
        builder: (context, provider, child) {
          final history = provider.history.reversed.toList();

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: AppConstants.textMuted.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No history found.',
                    style: TextStyle(fontSize: 18, color: AppConstants.textMuted),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final session = history[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isDark ? [] : AppConstants.softShadow,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      session.slotId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  title: Text(
                    Formatters.formatDate(session.startTime),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppConstants.textDark : AppConstants.textLight,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 16, color: AppConstants.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          Formatters.formatDuration(session.durationInSeconds),
                          style: TextStyle(color: AppConstants.textMuted),
                        ),
                      ],
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatCurrency(session.totalCost),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.availableColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completed',
                        style: TextStyle(fontSize: 10, color: AppConstants.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
