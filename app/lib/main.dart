import 'package:app/screens/friends.dart';
import 'package:app/screens/home.dart';
import 'package:app/screens/search.dart';
import 'package:app/screens/login.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  String token = '';
  int userID = 0;

  void login(String tokenLogin, int id) {
    setState(() {
      isLoggedIn = true;
      token = tokenLogin;
      userID = id;
    });
  }

  String getToken() {
    return token;
  }

  int getUserID() {
    return userID;
  }

  void logout() {
    setState(() {
      isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Future<void> _refreshScreen() async {
    // Simular uma atualização de 2 segundos
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Aqui você pode adicionar o que for necessário para atualizar os dados
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: _refreshScreen, // Para a aba Friends
              child: const FriendsScreen(),
            ),
            RefreshIndicator(
              onRefresh: _refreshScreen, // Para a aba Home
              child: const HomePage(),
            ),
            RefreshIndicator(
              onRefresh: _refreshScreen, // Para a aba Search
              child: const SearchScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
