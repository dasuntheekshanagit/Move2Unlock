import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepService {
  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;
  
  int _initialSteps = -1;
  int _currentSteps = 0;
  
  final _stepController = StreamController<int>.broadcast();
  Stream<int> get stepStream => _stepController.stream;

  Future<void> init() async {
    try {
      _stepCountStream = Pedometer.stepCountStream;
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

      _stepCountStream?.listen(_onStepCount).onError(_onStepCountError);
      _pedestrianStatusStream?.listen(_onPedestrianStatus).onError(_onPedestrianStatusError);
    } catch (e) {
      print('Error initializing pedometer: $e');
      // Rethrow so the UI knows something went wrong (e.g. sensor not found)
      throw Exception('Step sensor not available: $e');
    }
    
    await _loadTodaySteps();
  }

  Future<void> _loadTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString('last_step_date');
    
    if (savedDate != today) {
      // New day
      await prefs.setString('last_step_date', today);
      await prefs.setInt('initial_steps_today', -1); // Reset initial steps reference
      _initialSteps = -1;
      _currentSteps = 0;
    } else {
       _initialSteps = prefs.getInt('initial_steps_today') ?? -1;
       // We can't easily recover _currentSteps without a new sensor event, 
       // but we can store the last known count for today.
       _currentSteps = prefs.getInt('today_steps_count') ?? 0;
       _stepController.add(_currentSteps);
    }
  }

  void _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Check if date changed while app was running
    if (prefs.getString('last_step_date') != today) {
       await _loadTodaySteps();
    }

    if (_initialSteps == -1) {
      _initialSteps = event.steps;
      await prefs.setInt('initial_steps_today', _initialSteps);
    }
    
    // Calculate steps taken since app start/today
    // If event.steps < _initialSteps, it means device rebooted.
    if (event.steps < _initialSteps) {
      _initialSteps = event.steps; // Reset baseline
      await prefs.setInt('initial_steps_today', _initialSteps);
    }

    int stepsSinceInit = event.steps - _initialSteps;
    if (stepsSinceInit < 0) stepsSinceInit = 0;
    
    // We might want to add these to a "base" if we want to persist across reboots better,
    // but for now, let's stick to simple "steps since first event of the day".
    // To make it robust across app restarts, we should rely on the sensor's monotonic increase.
    
    _currentSteps = stepsSinceInit;
    
    // Save for history
    await prefs.setInt('today_steps_count', _currentSteps);
    await prefs.setInt('history_steps_$today', _currentSteps);
    
    _stepController.add(_currentSteps);
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    // print(event);
  }

  void _onStepCountError(error) {
    print('onStepCountError: $error');
    // _stepController.addError('Step Count not available');
  }

  void _onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
  }
  
  int getCurrentSteps() {
      return _currentSteps;
  }

  Future<Map<String, int>> getWeeklySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    Map<String, int> history = {};
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];
      final steps = prefs.getInt('history_steps_$dateStr') ?? 0;
      
      // Use weekday name as key (e.g., "Mon", "Tue")
      // Or just return the list of values.
      // Let's return a map with date keys for flexibility
      history[dateStr] = steps;
    }
    return history;
  }
  
  Future<int> getTotalStepsAllTime() async {
    final prefs = await SharedPreferences.getInstance();
    // This is a simple approximation. For a real app, we'd iterate all stored keys or keep a running total.
    // Let's iterate last 365 days for now or keep a separate counter.
    // Better: update a total counter on every step update.
    // For now, let's sum up the last 30 days.
    int total = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
       final date = now.subtract(Duration(days: i));
       final dateStr = date.toIso8601String().split('T')[0];
       total += prefs.getInt('history_steps_$dateStr') ?? 0;
    }
    return total;
  }
}
