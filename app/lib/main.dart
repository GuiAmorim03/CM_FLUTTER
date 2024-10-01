import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

final List<Map<String, dynamic>> locais = [
  {"id":1, "nome": "Big Ben", "distance": 1300, "coord":{"lat": 51.510357, "lng": -0.116773}, "visited": false},
  {"id":2, "nome": "Eiffel Tower", "distance": 1800, "coord":{"lat": 48.858093, "lng": 2.294694}, "visited": false},
  {"id":3, "nome": "Berlin Wall", "distance": 450, "coord":{"lat": 52.535152, "lng": 13.390206}, "visited": true},
  {"id":4, "nome": "Sagrada Familia", "distance": 230, "coord":{"lat": 41.403706, "lng": 2.173504}, "visited": false},
  {"id":5, "nome": "Colosseum", "distance": 800, "coord":{"lat": 41.890210, "lng": 12.492231}, "visited": true},
  {"id":6, "nome": "Statue of Liberty", "distance": 1200, "coord":{"lat": 40.689247, "lng": -74.044502}, "visited": true},
  {"id":7, "nome": "Taj Mahal", "distance": 1500, "coord":{"lat": 27.175015, "lng": 78.042155}, "visited": true},
  {"id":8, "nome": "Great Wall of China", "distance": 2000, "coord":{"lat": 40.431908, "lng": 116.570374}, "visited": false},
  {"id":9, "nome": "Machu Picchu", "distance": 3000, "coord":{"lat": -13.163141, "lng": -72.545894}, "visited": true},
  {"id":10, "nome": "Sydney Opera House", "distance": 4000, "coord":{"lat": -33.856784, "lng": 151.215296}, "visited": true},
  {"id":11, "nome": "Petra", "distance": 5000, "coord":{"lat": 30.328460, "lng": 35.441397}, "visited": false},
  {"id":12, "nome": "Chichen Itza", "distance": 6000, "coord":{"lat": 20.684289, "lng": -88.567781}, "visited": false},
  {"id":13, "nome": "Christ the Redeemer", "distance": 7000, "coord":{"lat": -22.951916, "lng": -43.210487}, "visited": false},
  {"id":14, "nome": "Machu Picchu", "distance": 8000, "coord":{"lat": -13.163141, "lng": -72.545894}, "visited": false},
  {"id":15, "nome": "Sydney Opera House", "distance": 9000, "coord":{"lat": -33.856784, "lng": 151.215296}, "visited": false},
  {"id":16, "nome": "Petra", "distance": 10000, "coord":{"lat": 30.328460, "lng": 35.441397}, "visited": false},
];

final List<Map<String, dynamic>> locaisTop5Nearby = (locais..sort((a, b) => a["distance"].compareTo(b["distance"]))).sublist(0, 5);

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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: locaisTop5Nearby.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(
                    Icons.place,
                    color: Colors.green.shade700,
                  ),
                  title: Text(
                    locais[index]["nome"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    "${locaisTop5Nearby[index]["distance"]}m",
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
                        builder: (context) => PoiScreen(
                          poiID: locais[index]["id"],
                        ),
                      ),
                    );
                  },
                  visualDensity: const VisualDensity(
                    vertical: 3,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(40.631375, -8.659969),  // UA
                initialZoom: 7,
                // interactionOptions: InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom)
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                MarkerLayer(markers: locais.map((local){
                  return Marker(
                    width: 80,
                    height: 80,
                    point: LatLng(local["coord"]["lat"], local["coord"]["lng"]),
                    child:
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PoiScreen(
                                poiID: local["id"],
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.location_pin,
                          size: 40,
                        color: local["visited"] == true
                            ? Colors.green.shade700 // locais já visitados
                            : Colors.greenAccent.shade700, // locais não visitados
                        ),
                      )
                  );
                }).toList())
              ],
            )
          )
        ],
      )
    );
  }
}

class PoiScreen extends StatefulWidget {
  const PoiScreen({super.key, required this.poiID});
  
  final int poiID;

  @override
  State<StatefulWidget> createState() {
    return _PoiScreenState();
  }
}

class _PoiScreenState extends State<PoiScreen> {

  @override
  Widget build(BuildContext context) {
    final poi = locais.firstWhere((element) => element["id"] == widget.poiID);
    print(poi);

    return Scaffold(
      appBar: AppBar(
        title: Text(poi["nome"]),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: 
        Center(
          child: Column(
            children: <Widget>[
              
              if (poi.containsKey("imagePath") && poi["imagePath"] != null)
                Image.file(
                  File(poi["imagePath"]),
                  width: 300,
                  height: 600,
                  fit: BoxFit.cover,
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    final imagePath = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(poiID: widget.poiID),
                      ),
                    );

                    if (imagePath != null && imagePath.isNotEmpty) {
                      setState(() {
                        poi["imagePath"] = imagePath;
                      });
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green.shade700),
                  ),
                  child: const Text('Usar Câmera'),
                ),
            ],
          ),
        ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.poiID});

  final int poiID;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras![0], ResolutionPreset.high);
    await _controller!.initialize();
    setState(() {});
  }

  Future<void> takePicture() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final picture = await _controller!.takePicture();
      setState(() {
        _capturedImage = picture;
      });
      await _controller?.dispose();
      _controller = null;
    }
  }

  Future<String> _saveImage() async {

    final Directory appDir = await getApplicationDocumentsDirectory();

    final String newPath = '${appDir.path}/foto_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final File newImage = await File(_capturedImage!.path).copy(newPath);
    return newPath;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Câmera'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _capturedImage == null
          ? _buildCameraPreview()  
          : _buildCapturedImage(),
    );
  }

  // Câmara a funcionar
  Widget _buildCameraPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      children: [
        CameraPreview(_controller!),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.green.shade700,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await takePicture();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    backgroundColor: Colors.white,
                  ),
                  child: const Icon(
                    Icons.camera_alt
                  ),
                ),
              ],
            ),
          ),
        ),
      ]
    );
  }

  // Foto Tirada
  Widget _buildCapturedImage() {
    return Stack(
      children: [
        Image.file(File(_capturedImage!.path)),
        Align(
          alignment: Alignment.bottomCenter,
          child:
          Container(
            color: Colors.green.shade700,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _capturedImage = null;
                      initCamera();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Repetir",
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final imagePath = await _saveImage();
                    Navigator.pop(context, imagePath);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    backgroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Guardar",
                  ),
                )
              ],
            ),
          )
        )
      ]
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
