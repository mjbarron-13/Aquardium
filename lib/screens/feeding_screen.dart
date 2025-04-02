import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../providers/feed_provider.dart';

class FeederScreen extends StatefulWidget {
  @override
  _FeederScreenState createState() => _FeederScreenState();
}

class _FeederScreenState extends State<FeederScreen> {
  final _formKey = GlobalKey<FormState>();
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final TextEditingController _feedAmountController = TextEditingController();
  final TextEditingController _feedIntervalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _initializeFormFields();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedProvider>(context, listen: false).startDataSimulation();
    });
  }

  @override
  void dispose() {
    _feedAmountController.dispose();
    _feedIntervalController.dispose();
    Provider.of<FeedProvider>(context, listen: false).stopDataSimulation();
    super.dispose();
  }

  void _initializeFormFields() {
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    _feedAmountController.text = feedProvider.feedAmount.toString();
    _feedIntervalController.text = feedProvider.feedInterval.toString();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _sendPushNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
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

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Feed Left'),
          content: Text('The fish feeder has run out of feed.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final feedProvider = Provider.of<FeedProvider>(context, listen: false);
      feedProvider.updateFeedSettings(
        double.parse(_feedAmountController.text),
        int.parse(_feedIntervalController.text),
      );
      feedProvider.startDepletionTimer(
        onDepletion: () {
          _showAlertDialog(context);
          _sendPushNotification();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);

    // Show a non-invasive dialog if feed is depleted and notification hasn't been acknowledged
    if (feedProvider.remainingFeed == 0 && !feedProvider.notificationShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Feed Depleted!'),
              content: Text('The fish feeder has run out of feed. Please refill it to continue.'),
              actions: [
                TextButton(
                  onPressed: () {
                    feedProvider.resetNotificationFlag(); // Reset the flag
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Feeding Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Feeding Interval (Hours)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _feedIntervalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter interval in hours',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid interval.';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Interval must be greater than 0.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Feed Amount (g)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: _feedAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter feed amount in g',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid amount.';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Amount must be greater than 0.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Remaining Feed: ${feedProvider.remainingFeed.toStringAsFixed(1)} g',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              LinearProgressIndicator(
                value: feedProvider.remainingFeed / 50,
                backgroundColor: Colors.grey[300],
                color: feedProvider.remainingFeed < 10 ? Colors.red : Colors.blue,
                minHeight: 20,
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: feedProvider.remainingFeed >=
                          feedProvider.feedAmount
                      ? () => _submitForm(context)
                      : null,
                  child: Text('Start Simulation'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
