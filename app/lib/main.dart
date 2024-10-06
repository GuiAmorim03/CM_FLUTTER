import 'package:app/screens/friends.dart';
import 'package:app/screens/home.dart';
import 'package:app/screens/search.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
        useMaterial3: true,
      ),
      home: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.people)),
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.search)),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              FriendsScreen(),
              HomePage(),
              SearchScreen(),
            ],
          ),
        ),
      ),
    );
  }
}