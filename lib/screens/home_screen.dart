import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/parking_slot.dart';
import '../providers/parking_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/slot_grid_item.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';
import 'slot_detail_screen.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final parkingProvider = Provider.of<ParkingProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final rawFloors = parkingProvider.slots.map((s) => s.floorName).toSet().toList();
    final availableCount = parkingProvider.slots.where((s) => s.status == SlotStatus.available).length;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.backgroundDark : AppConstants.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, availableCount, themeProvider),
            _buildSearchAndFilters(context, parkingProvider, isDark),
            Expanded(
              child: DefaultTabController(
                length: rawFloors.length,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: isDark ? AppConstants.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isDark ? [] : AppConstants.softShadow,
                      ),
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: AppConstants.textMuted,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        dividerColor: Colors.transparent,
                        tabs: rawFloors.map((f) => Tab(text: f)).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: rawFloors.map((floor) {
                          final floorSlots = parkingProvider.filteredSlots
                              .where((s) => s.floorName == floor)
                              .toList();
                          
                          if (floorSlots.isEmpty) {
                            return Center(
                              child: Text(
                                'No matching slots found on this floor.', 
                                style: TextStyle(color: AppConstants.textMuted, fontSize: 16),
                              ),
                            );
                          }

                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                            // Fluid Grid for all screen sizes!
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 180,
                              childAspectRatio: 0.85,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: floorSlots.length,
                            itemBuilder: (context, index) {
                              return SlotGridItem(
                                slot: floorSlots[index],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SlotDetailScreen(
                                        slotId: floorSlots[index].id,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, ParkingProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Field
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppConstants.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? [] : AppConstants.softShadow,
            ),
            child: TextField(
              onChanged: (val) => provider.setSearchQuery(val),
              style: TextStyle(color: isDark ? AppConstants.textDark : AppConstants.textLight),
              decoration: InputDecoration(
                hintText: 'Search slot by ID (e.g. A1)',
                hintStyle: TextStyle(color: AppConstants.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppConstants.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filter Chips (Using Wrap to prevent overflow robustly)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('All', null, provider, isDark),
              _buildFilterChip('Available', SlotStatus.available, provider, isDark),
              _buildFilterChip('Occupied', SlotStatus.occupied, provider, isDark),
              _buildFilterChip('Reserved', SlotStatus.reserved, provider, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, SlotStatus? statusValue, ParkingProvider provider, bool isDark) {
    bool isSelected = provider.filterStatus == statusValue;
    
    return GestureDetector(
      onTap: () => provider.setFilterStatus(statusValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppConstants.primaryColor 
              : (isDark ? AppConstants.surfaceDark : AppConstants.backgroundLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppConstants.primaryColor 
                : (isDark ? AppConstants.surfaceLight.withOpacity(0.1) : AppConstants.textMuted.withOpacity(0.2)),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppConstants.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Colors.white 
                : (isDark ? AppConstants.textDark : AppConstants.textLight),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, int availableCount, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: isDark ? [] : AppConstants.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, Driver 👋',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppConstants.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Find Parking',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppConstants.textDark : AppConstants.textLight,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildIconButton(Icons.analytics_rounded, AppConstants.primaryColor, isDark, () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
                  }),
                  const SizedBox(width: 8),
                  _buildIconButton(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, AppConstants.primaryColor, isDark, () {
                    themeProvider.toggleTheme();
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppConstants.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.local_parking_rounded, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AVAILABLE SLOTS',
                        style: TextStyle(
                          color: Colors.white70, 
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$availableCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return Material(
      color: isDark ? AppConstants.backgroundDark : AppConstants.backgroundLight,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}
