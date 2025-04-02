// File: main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/feed_provider.dart'; // Import FeedProvider without screen references

import 'screens/feeding_screen.dart';
import 'screens/temperature_turbidity_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FeedProvider>(
          create: (context) => FeedProvider(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aquardium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins', // Custom font
      ),
      home: HomePage(),
    );
  }
}

// Home Screen with Tab Navigation

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FeedProvider(), // Provide FeedProvider to both tabs
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Aquardium App'),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.food_bank), text: 'Feeding'),
                Tab(icon: Icon(Icons.thermostat), text: 'Temp & Turbidity'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              FeederScreen(),        // Tab 1: Feeder Settings
              TempTurbScreen(),      // Tab 2: Temp & Turbidity
            ],
          ),
        ),
      ),
    );
  }
}







