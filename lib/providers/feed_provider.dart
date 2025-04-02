import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FeedProvider with ChangeNotifier, WidgetsBindingObserver {
  double _remainingFeed = 50.0;
  double _feedAmount = 10.0;
  int _feedInterval = 4; // In seconds for testing
  Timer? _timer;
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  double _temperature = 25.0;
  double _turbidity = 2.0;
  List<Map<String, dynamic>> _highRecords = [];
  Timer? _dataSimulationTimer;

  bool _notificationShown = false; // Flag to track notification state

  double get remainingFeed => _remainingFeed;
  double get feedAmount => _feedAmount;
  int get feedInterval => _feedInterval;
  double get temperature => _temperature;
  double get turbidity => _turbidity;
  List<Map<String, dynamic>> get highRecords => List.unmodifiable(_highRecords);
  bool get notificationShown => _notificationShown;

  set notificationShown(bool value) {
    _notificationShown = value;
    notifyListeners();
  }

  FeedProvider() {
    _initializeNotifications();
    _requestNotificationPermission();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Track App Lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      print('App is in background');
    } else if (state == AppLifecycleState.resumed) {
      print('App is active again');
    }
    super.didChangeAppLifecycleState(state);
  }

  /// Initialize Notifications
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create notification channel for Android 12+
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channelId',
      'Fish Feeder Alerts',
      description: 'Notifications for feeder status',
      importance: Importance.high,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Request Notification Permission
  Future<void> _requestNotificationPermission() async {
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final isEnabled = await androidImplementation?.areNotificationsEnabled();
    if (isEnabled == false || isEnabled == null) {
      await androidImplementation?.requestPermission();
    }
  }

  /// Send Push Notification
  Future<void> _sendPushNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channelId', // Matches the channel created
      'Fish Feeder Alerts',
      channelDescription: 'Alerts when the fish feeder is empty',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      styleInformation: BigTextStyleInformation(
        'The fish feeder has run out of food. Please refill it to keep your fish healthy.',
        contentTitle: 'Fish Feeder Alert',
        summaryText: 'No feed left to dispense!',
      ),
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Fish Feeder Alert',
      'No feed left to dispense!',
      notificationDetails,
    );
  }

  /// Update Feed Settings
  void updateFeedSettings(double feedAmount, int feedInterval) {
    _feedAmount = feedAmount;
    _feedInterval = feedInterval;
    _remainingFeed = 50.0; // Reset to full
    notifyListeners();
  }

  /// Reset Notification Flag
  void resetNotificationFlag() {
    _notificationShown = false; // Reset the flag when acknowledged
    notifyListeners();
  }

  /// Start Depletion Timer
  void startDepletionTimer({required Function onDepletion}) {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: _feedInterval), (timer) {
      if (_remainingFeed > 0) {
        _remainingFeed = (_remainingFeed - _feedAmount).clamp(0, 50);
        notifyListeners();

        if (_remainingFeed == 0 && !_notificationShown) {
          _sendPushNotification();
          _notificationShown = true; // Set the flag to true
          onDepletion();
          notifyListeners(); // Notify UI to show the notification screen
          timer.cancel();
        }
      }
    });
  }

  /// Start Simulating Temperature and Turbidity Data
  void startDataSimulation() {
    _dataSimulationTimer?.cancel();
    _dataSimulationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _temperature = 22 + Random().nextDouble() * 10; // 22-32°C
      _turbidity = Random().nextDouble() * 10; // 0-10 NTU

      if (_temperature > 27) {
        _highRecords.add({
          'type': 'Temperature',
          'value': _temperature.toStringAsFixed(2),
          'time': DateTime.now().toString().split('.')[0], // Remove milliseconds
        });
      }

      if (_turbidity > 5) {
        _highRecords.add({
          'type': 'Turbidity',
          'value': _turbidity.toStringAsFixed(2),
          'time': DateTime.now().toString().split('.')[0], // Remove milliseconds
        });
      }

      notifyListeners();
    });
  }

  /// Stop Data Simulation
  void stopDataSimulation() {
    _dataSimulationTimer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dataSimulationTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}