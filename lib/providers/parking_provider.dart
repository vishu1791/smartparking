import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/parking_session.dart';
import '../models/parking_slot.dart';
import '../utils/constants.dart';

class ParkingProvider extends ChangeNotifier {
  List<ParkingSlot> _slots = [];
  List<ParkingSession> _history = [];
  Timer? _timer;
  int _activeTicks = 0; // Trigger UI updates

  // Search & Filter State
  String _searchQuery = '';
  SlotStatus? _filterStatus;

  List<ParkingSlot> get slots => _slots;
  List<ParkingSession> get history => _history;
  SlotStatus? get filterStatus => _filterStatus;

  ParkingProvider() {
    _initProvider();
    _startTimer();
  }

  void _initProvider() async {
    await _loadState();
    if (_slots.isEmpty) {
      _generateDummySlots();
      _saveState();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool needsUpdate = false;
      final now = DateTime.now();

      for (var slot in _slots) {
        if (slot.status == SlotStatus.occupied) {
          needsUpdate = true;
        } else if (slot.status == SlotStatus.reserved && slot.startTime != null) {
          needsUpdate = true;
          // Auto release if 5 minutes have passed
          if (now.difference(slot.startTime!).inSeconds >= 300) {
            slot.status = SlotStatus.available;
            slot.startTime = null;
            _saveState();
          }
        }
      }
      if (needsUpdate) {
        _activeTicks++;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateDummySlots() {
    _slots = [
      ...List.generate(8, (i) => ParkingSlot(id: 'A${i + 1}', floorName: 'Floor 1')),
      ...List.generate(8, (i) => ParkingSlot(id: 'B${i + 1}', floorName: 'Floor 2')),
    ];
  }

  ParkingSlot getSlotById(String id) {
    return _slots.firstWhere((s) => s.id == id);
  }

  void reserveSlot(String id) {
    var slot = getSlotById(id);
    if (slot.status == SlotStatus.available) {
      slot.status = SlotStatus.reserved;
      slot.startTime = DateTime.now();
      _saveState();
      notifyListeners();
    }
  }

  void startParking(String id) {
    var slot = getSlotById(id);
    if (slot.status == SlotStatus.available || slot.status == SlotStatus.reserved) {
      slot.status = SlotStatus.occupied;
      slot.startTime = DateTime.now();
      slot.endTime = null;
      _saveState();
      notifyListeners();
    }
  }

  ParkingSession? endParking(String id) {
    var slot = getSlotById(id);
    if (slot.status == SlotStatus.occupied) {
      slot.status = SlotStatus.available;
      slot.endTime = DateTime.now();
      
      int durationInSeconds = slot.endTime!.difference(slot.startTime!).inSeconds;
      
      int hours = (durationInSeconds / 3600).ceil();
      if (hours == 0) hours = 1; // Minimum 1 hour charge
      double totalCost = hours * AppConstants.hourlyRate;
      
      var session = ParkingSession(
        slotId: slot.id,
        startTime: slot.startTime!,
        endTime: slot.endTime!,
        durationInSeconds: durationInSeconds,
        totalCost: totalCost,
      );
      
      _history.add(session);
      
      // Reset
      slot.startTime = null;
      slot.endTime = null;
      
      _saveState();
      notifyListeners();
      return session;
    }
    return null;
  }

  int getCurrentDurationInSeconds(String id) {
    var slot = getSlotById(id);
    if (slot.status == SlotStatus.occupied && slot.startTime != null) {
      return DateTime.now().difference(slot.startTime!).inSeconds;
    }
    return 0;
  }

  int getRemainingReservationSeconds(String id) {
    var slot = getSlotById(id);
    if (slot.status == SlotStatus.reserved && slot.startTime != null) {
      int passed = DateTime.now().difference(slot.startTime!).inSeconds;
      int remaining = 300 - passed;
      return remaining > 0 ? remaining : 0;
    }
    return 0;
  }

  // --- Filtering & Search Logic ---
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterStatus(SlotStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  List<ParkingSlot> get filteredSlots {
    return _slots.where((slot) {
      final matchesSearch = slot.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _filterStatus == null || slot.status == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  // --- Analytics Logic ---
  double get totalEarnings {
    return _history.fold(0.0, (sum, session) => sum + session.totalCost);
  }

  int get totalParkedVehicles {
    return _history.length;
  }

  String get mostUsedSlotName {
    if (_history.isEmpty) return 'N/A';
    
    var counts = <String, int>{};
    for (var session in _history) {
      counts[session.slotId] = (counts[session.slotId] ?? 0) + 1;
    }
    
    String mostUsed = counts.keys.first;
    int maxCount = counts[mostUsed]!;
    
    counts.forEach((slot, count) {
      if (count > maxCount) {
         maxCount = count;
         mostUsed = slot;
      }
    });

    return mostUsed;
  }

  // --- Persistence Logic ---
  static const String _slotsKey = 'parking_slots';
  static const String _historyKey = 'parking_history';

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String> slotsJson = _slots.map((s) => json.encode(s.toJson())).toList();
    List<String> historyJson = _history.map((h) => json.encode(h.toJson())).toList();
    
    await prefs.setStringList(_slotsKey, slotsJson);
    await prefs.setStringList(_historyKey, historyJson);
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    
    List<String>? slotsJson = prefs.getStringList(_slotsKey);
    List<String>? historyJson = prefs.getStringList(_historyKey);
    
    if (slotsJson != null) {
      _slots = slotsJson.map((s) => ParkingSlot.fromJson(json.decode(s))).toList();
    }
    if (historyJson != null) {
      _history = historyJson.map((h) => ParkingSession.fromJson(json.decode(h))).toList();
    }
  }
}
