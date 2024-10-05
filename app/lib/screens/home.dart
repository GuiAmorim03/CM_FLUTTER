
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../models/locais.dart';
import 'poi.dart';

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
      return Future.error('Localização desativada');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão negada');
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentPosition!, 8);
      _updateDistanceToLocals();
    });
  }

  void _updateDistanceToLocals() {
    if (_currentPosition != null) {
      for (var local in locais) {
        final double distance = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, local["coord"]["lat"], local["coord"]["lng"]);
        local["distance"] = distance.round();
      }
      _updateTop10NearbyLocals();
      setState(() {});  // atualizar a interface
    }
  }

  List<Map<String, dynamic>> locaisTop10Nearby = [];
  void _updateTop10NearbyLocals() {
    locaisTop10Nearby = (locais..sort((a, b) => a["distance"].compareTo(b["distance"]))).sublist(0, 10);
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
                  itemCount: locaisTop10Nearby.length,
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
                        _formatDistance(locaisTop10Nearby[index]["distance"]),
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
                        _mapController.move(LatLng(locaisTop10Nearby[index]["coord"]["lat"], locaisTop10Nearby[index]["coord"]["lng"]), 13);
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
                        activeColor: Colors.greenAccent.shade700,
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
                initialZoom: 8,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _mapController.move(_currentPosition!, 13);
          });
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}

