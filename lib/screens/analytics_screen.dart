import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/parking_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final provider = Provider.of<ParkingProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? AppConstants.backgroundDark : AppConstants.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppConstants.textDark : AppConstants.textLight,
        ),
        title: Text(
          'Analytics',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Earnings',
                    Formatters.formatCurrency(provider.totalEarnings),
                    Icons.monetization_on,
                    AppConstants.availableGradient,
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Vehicles Parked',
                    '${provider.totalParkedVehicles}',
                    Icons.local_shipping,
                    AppConstants.primaryGradient,
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
             _buildStatCard(
                'Most Used Slot',
                provider.mostUsedSlotName,
                Icons.star,
                AppConstants.reservedGradient,
                isDark,
              ),
            const SizedBox(height: 48),
            Text(
              'REVENUE OVER TIME (Simplified)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                color: AppConstants.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppConstants.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isDark ? [] : AppConstants.softShadow,
              ),
              child: provider.history.isEmpty
                  ? Center(
                      child: Text('Not enough data to display chart.',
                          style: TextStyle(color: AppConstants.textMuted)),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: provider.totalEarnings > 0 ? (provider.totalEarnings * 1.5) : 100,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < provider.history.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      provider.history[value.toInt()].slotId,
                                      style: TextStyle(color: AppConstants.textMuted, fontSize: 10),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                           provider.history.length > 5 ? 5 : provider.history.length,
                          (i) {
                            final session = provider.history[i];
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: session.totalCost,
                                  gradient: AppConstants.primaryGradient,
                                  width: 20,
                                  borderRadius: BorderRadius.circular(6),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, LinearGradient gradient, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? [] : AppConstants.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: TextStyle(fontSize: 14, color: AppConstants.textMuted),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppConstants.textDark : AppConstants.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
