import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

final List<Map<String, dynamic>> locais = [
  {"id":1, "nome": "Big Ben", "distance": "1.3km", "king":"shrek"},
  {"id":2, "nome": "Eiffel Tower", "distance": "1.8km", "king":"shrek"},
  {"id":3, "nome": "Berlin Wall", "distance": "450m", "king":"shrek"},
];

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
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.people)),
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.account_circle)),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              MyHomePage(title: 'People'),
              HomePage(),
              MyHomePage(title: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: locais.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(
              Icons.place,
              color: Colors.green.shade700
            ),
            title: Text(
              locais[index]["nome"],
              style: const TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            trailing: Text(
              locais[index]["distance"],
              style: TextStyle(
                color: Colors.green.shade700,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: BorderSide(
                color: Colors.green.shade700,
                width: .25,
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PoiScreen(poiID: locais[index]["id"]),
                ),
              );
            },
            visualDensity: const VisualDensity(
              horizontal: 3,
              vertical: 3,
            ),
          );
        },
      ),
    );
  }
}

class PoiScreen extends StatelessWidget {
  const PoiScreen({super.key, required this.poiID});

  final int poiID;

  @override
  Widget build(BuildContext context) {
    final poi = locais.firstWhere((element) => element["id"] == poiID);

    return Scaffold(
      appBar: AppBar(
        title: Text(poi["nome"]),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              poi["nome"],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Text(
              poi["distance"],
              style: const TextStyle(
                fontSize: 18,
              ),    
            ),
            Text(
              poi["king"],
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
