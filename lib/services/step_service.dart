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
    _stepCountStream = Pedometer.stepCountStream;
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    _stepCountStream?.listen(_onStepCount).onError(_onStepCountError);
    _pedestrianStatusStream?.listen(_onPedestrianStatus).onError(_onPedestrianStatusError);
    
    // Load saved initial steps for the day if app was restarted
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString('last_step_date');
    
    if (savedDate != today) {
      // New day, reset relative counter logic
      await prefs.setString('last_step_date', today);
      _initialSteps = -1; // Will be set on first event
    } else {
       _initialSteps = prefs.getInt('initial_steps_today') ?? -1;
    }
  }

  void _onStepCount(StepCount event) async {
    if (_initialSteps == -1) {
      _initialSteps = event.steps;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('initial_steps_today', _initialSteps);
    }
    
    // Calculate steps taken since app start/today
    _currentSteps = event.steps - _initialSteps;
    if (_currentSteps < 0) _currentSteps = 0; // Handle reboot cases roughly
    
    _stepController.add(_currentSteps);
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    print(event);
  }

  void _onStepCountError(error) {
    print('onStepCountError: $error');
    _stepController.addError('Step Count not available');
  }

  void _onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
  }
  
  int getCurrentSteps() {
      return _currentSteps;
  }
}
