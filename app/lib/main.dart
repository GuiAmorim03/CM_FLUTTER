import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

final List<Map<String, dynamic>> locais = [
  {"id":1, "nome": "Big Ben", "coord":{"lat": 51.510357, "lng": -0.116773}},
  {"id":2, "nome": "Eiffel Tower", "coord":{"lat": 48.858093, "lng": 2.294694}},
  {"id":3, "nome": "Berlin Wall", "coord":{"lat": 52.535152, "lng": 13.390206}, "visited": {"path": "photos/colosseum.jpg", "date": "2024-10-01"}},
  {"id":4, "nome": "Sagrada Familia", "coord":{"lat": 41.403706, "lng": 2.173504}},
  {"id":5, "nome": "Colosseum", "coord":{"lat": 41.890210, "lng": 12.492231}, "visited": {"path": "photos/colosseum.jpg", "date": "2024-10-01"}},
  {"id":6, "nome": "Statue of Liberty", "coord":{"lat": 40.689247, "lng": -74.044502}, "visited": {"path": "photos/colosseum.jpg", "date": "2024-10-01"}},
  {"id":7, "nome": "Taj Mahal", "coord":{"lat": 27.175015, "lng": 78.042155}, "visited": {"path": "photos/colosseum.jpg", "date": "2024-10-01"}},
  {"id":8, "nome": "Great Wall of China", "coord":{"lat": 40.431908, "lng": 116.570374}},
  {"id":9, "nome": "Machu Picchu", "coord":{"lat": -13.163141, "lng": -72.545894}, "visited": {"path": "photos/colosseum.jpg", "date": "2024-10-01"}},
  {"id":10, "nome": "Sydney Opera House", "coord":{"lat": -33.856784, "lng": 151.215296}, "visited": {"path": "photos/colosseum.jpg", "date": "2024-10-01"}},
  {"id":11, "nome": "Petra", "coord":{"lat": 30.328460, "lng": 35.441397}},
  {"id":12, "nome": "Chichen Itza", "coord":{"lat": 20.684289, "lng": -88.567781}},
  {"id":13, "nome": "Christ the Redeemer", "coord":{"lat": -22.951916, "lng": -43.210487}},
  {"id":14, "nome": "Machu Picchu", "coord":{"lat": -13.163141, "lng": -72.545894}},
  {"id":15, "nome": "Sydney Opera House", "coord":{"lat": -33.856784, "lng": 151.215296}},
  {"id":16, "nome": "Petra", "coord":{"lat": 30.328460, "lng": 35.441397}},
  {"id":17, "nome": "Chichen Itza", "coord":{"lat": 20.684289, "lng": -88.567781}},
  {"id":18, "nome": "Christ the Redeemer", "coord":{"lat": -22.951916, "lng": -43.210487}},
  {"id":19, "nome": "Ponte 25 de Abril", "coord": {"lat": 38.6916, "lng": -9.1774}},
  {"id":20, "nome": "Cristo Rei", "coord": {"lat": 38.6780, "lng": -9.1670}},
  {"id":21, "nome": "Livraria Lello", "coord": {"lat": 41.1466, "lng": -8.6114}, "visited": {"path": "photos/colosseum.jpg", "date": "2024-10-01"}},
  {"id":22, "nome": "Mosteiro da Batalha", "coord": {"lat": 39.6603, "lng": -8.8243}},
  {"id":23, "nome": "Mosteiro de Alcobaça", "coord": {"lat": 39.5513, "lng": -8.9774}, "visited": {"path": "photos/colosseum.jpg", "date": "2024-10-01"}},
  {"id":24, "nome": "Palácio da Pena", "coord": {"lat": 38.7876, "lng": -9.3900}},
  {"id":25, "nome": "Sé de Aveiro", "coord": {"lat": 40.6401, "lng": -8.6538}}, 
];

List<Map<String, dynamic>> locaisTop5Nearby = [];
void _updateTop5NearbyLocals() {
  locaisTop5Nearby = (locais..sort((a, b) => a["distance"].compareTo(b["distance"]))).sublist(0, 5);
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
  LatLng? _currentPosition;

  final MapController _mapController = MapController();

  bool _mostrarLocaisVisitados = true;
  bool _mostrarLocaisNaoVisitados = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização foi negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permissão de localização foi permanentemente negada.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentPosition!, 7);
      _updateDistanceToLocals();
    });
  }

  void _updateDistanceToLocals() {
    if (_currentPosition != null) {
      for (var local in locais) {
        final double distance = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, local["coord"]["lat"], local["coord"]["lng"]);
        local["distance"] = distance.round();
      }
      _updateTop5NearbyLocals();
      setState(() {});  // atualizar a interface
    }
  }

  String _formatDistance(int distance) {
    if (distance < 1000) {
      return "${distance}m";
    } else if (distance < 10000) {
      return "${(distance / 1000).toStringAsFixed(1)}km";
    } else {
      return "${(distance / 1000).toStringAsFixed(0)}km";
    }
  }

  List<Marker> _filterMarkers() {
    return locais.where((local) {
      bool isVisited = local.containsKey("visited");
      if (_mostrarLocaisVisitados && isVisited) return true;
      if (_mostrarLocaisNaoVisitados && !isVisited) return true;
      return false;
    }).map((local) {
      return Marker(
        width: 80,
        height: 80,
        point: LatLng(local["coord"]["lat"], local["coord"]["lng"]),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PoiScreen(poiID: local["id"]),
              ),
            );
          },
          child: Icon(
            Icons.location_pin,
            size: 40,
            color: local["visited"] != null
                ? Colors.green.shade700 // locais já visitados
                : Colors.greenAccent.shade700, // locais não visitados
          ),
        ),
      );
    }).toList();
  }

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
              child: _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                :
                ListView.builder(
                  itemCount: locaisTop5Nearby.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      tileColor: Colors.white,
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
                        _formatDistance(locaisTop5Nearby[index]["distance"]),
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
                        vertical: 2,
                      ),
                    );
                  },
                ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _mostrarLocaisVisitados,
                        onChanged: (bool? value) {
                          setState(() {
                            _mostrarLocaisVisitados = value!;
                          });
                        },
                      ),
                      const Text('Visited'),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _mostrarLocaisNaoVisitados,
                        onChanged: (bool? value) {
                          setState(() {
                            _mostrarLocaisNaoVisitados = value!;
                          });
                        },
                      ),
                      const Text('Non Visited'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition ?? const LatLng(40.631375, -8.659969),  // UA
                initialZoom: 7,
                // interactionOptions: InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom)
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                ),
                MarkerLayer(markers: _filterMarkers()),

                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80,
                        height: 80,
                        point: _currentPosition!,
                        child: Icon(
                          Icons.share_location_rounded,
                          size: 40,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
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

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
              if (poi.containsKey("visited") && poi["visited"]["path"] != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: poi["visited"]["path"].startsWith("photos")
                    ? Image.asset(
                      poi["visited"]["path"],
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.5,
                      fit: BoxFit.cover,
                    )
                    : Image.file(
                      File(poi["visited"]["path"]),
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.5,
                      fit: BoxFit.cover,
                    ),
                )
              else
                Row( 
                  children: <Widget>[
                    Image.asset(
                      "photos/no-photo.jpg",
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.5,
                      fit: BoxFit.cover,
                    ),      
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
                            poi["visited"] = {"path": imagePath, "date": DateTime.now().toIso8601String()};
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.all(10.0),
                        alignment: Alignment.center,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
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
