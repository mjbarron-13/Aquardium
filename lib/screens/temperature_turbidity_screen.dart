import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';

class TempTurbScreen extends StatefulWidget {
  @override
  _TempTurbScreenState createState() => _TempTurbScreenState();
}

class _TempTurbScreenState extends State<TempTurbScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      debugPrint('Starting data simulation...');
      Provider.of<FeedProvider>(context, listen: false).startDataSimulation();
    });
  }

  @override
  void dispose() {
    debugPrint('Stopping data simulation...');
    Provider.of<FeedProvider>(context, listen: false).stopDataSimulation();
    super.dispose();
  }

  /// Show Feed Depletion Dialog
  void _showFeedDepletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Feed Depleted!'),
          content: Text('The fish feeder has run out of feed. Please refill it to continue.'),
          actions: [
            TextButton(
              onPressed: () {
                Provider.of<FeedProvider>(context, listen: false).resetNotificationFlag();
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = Provider.of<FeedProvider>(context);

    debugPrint('Building Temperature & Turbidity Screen...');
    debugPrint('Remaining Feed: ${feedProvider.remainingFeed}');
    debugPrint('Temperature: ${feedProvider.temperature}');
    debugPrint('Turbidity: ${feedProvider.turbidity}');

    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature & Turbidity'),
      ),
      body: Builder(
        builder: (scaffoldContext) {
          // Trigger the dialog if feed is depleted and notification hasn't been acknowledged
          if (feedProvider.remainingFeed == 0 && !feedProvider.notificationShown) {
            WidgetsBinding.instance?.addPostFrameCallback((_) {
              debugPrint('Feed depleted. Showing dialog...');
              _showFeedDepletionDialog(scaffoldContext); // Use scaffoldContext
              feedProvider.notificationShown = true; // Prevent multiple triggers
            });
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Temperature Indicator
                _buildIndicator(
                  label: 'Temperature (°C)',
                  value: feedProvider.temperature,
                  color: _getColor(feedProvider.temperature, 'Temperature'),
                ),
                SizedBox(height: 20),

                // Turbidity Indicator
                _buildIndicator(
                  label: 'Turbidity (NTU)',
                  value: feedProvider.turbidity,
                  color: _getColor(feedProvider.turbidity, 'Turbidity'),
                ),
                SizedBox(height: 20),

                // High Records Log
                Text(
                  'High Records',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: feedProvider.highRecords.length,
                    itemBuilder: (context, index) {
                      final record = feedProvider.highRecords[index];
                      return ListTile(
                        leading: Icon(
                          record['type'] == 'Temperature'
                              ? Icons.thermostat
                              : Icons.opacity,
                          color: record['type'] == 'Temperature'
                              ? Colors.orange
                              : Colors.blue,
                        ),
                        title: Text('${record['type']} - ${record['value']}'),
                        subtitle: Text(record['time']),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Circular Indicator Widget
  Widget _buildIndicator({
    required String label,
    required double value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          width: 150,
          height: 150,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: value > 10 ? 1.0 : value / 10,
                strokeWidth: 12,
                backgroundColor: Colors.grey[300],
                color: color,
              ),
              Center(
                child: Text(
                  value.toStringAsFixed(2),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get Color Based on Value
  Color _getColor(double value, String type) {
    if (type == 'Temperature') {
      return value > 27 ? Colors.red : Colors.blue;
    } else {
      return value > 5 ? Colors.red : Colors.blue;
    }
  }
}

