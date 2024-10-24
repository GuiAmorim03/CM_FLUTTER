import 'dart:async';
import 'dart:math';

import 'package:app/main.dart';
import 'package:app/models/local.dart';
import 'package:app/services/local_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'poi.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _shakeThreshold = 50;
  StreamSubscription? _accelerometerSubscription;

  String token = '';
  int userID = 0;
  LatLng? _currentPosition;

  final MapController _mapController = MapController();

  bool _mostrarLocaisVisitados = true;
  bool _mostrarLocaisNaoVisitados = true;

  List<Local> _locais = [];
  List<Local> _locaisVisited = [];
  @override
  void initState() {
    super.initState();
    _getSession();
    _getLocais();
    _getCurrentLocation();
    _startListeningToShake();
  }

  void _startListeningToShake() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      double acceleration =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (acceleration > _shakeThreshold) {
        _onShakeDetected();
      }
    });
  }

  void _onShakeDetected() {
    var closestLocal = _locaisTop10Nearby[0];
    var closestDistance = closestLocal.distance;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: closestDistance < 100
              ? const Text('Nearby point!')
              : const Text('No nearby points'),
          content: closestDistance < 100
              ? Text(
                  'You are ${_formatDistance(closestDistance)} away from ${_locaisTop10Nearby[0].name}.')
              : const Text('There are no nearby points within 100 meters.'),
          actions: <Widget>[
            TextButton(
              child:
                  closestDistance < 100 ? const Text('GO') : const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                closestDistance < 100
                    ? Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PoiScreen(
                              poi: closestLocal, poiID: closestLocal.id),
                        ),
                      )
                    : null;
              },
            ),
          ],
        );
      },
    );
  }

  Future _getSession() async {
    final myAppState = context.findAncestorStateOfType<MyAppState>();
    token = myAppState!.getToken();
    userID = myAppState.getUserID();
  }

  Future<void> _getLocais() async {
    final localService = LocalService();
    _locais = await localService.fetchLocais();
    _locaisVisited = await localService.fetchLocaisVisitados(userID);
    for (var local in _locais) {
      if (_locaisVisited.any((element) => element.id == local.id)) {
        local.visitedByCurrentUser = true;
      }
    }
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

    // nao esquecer fazer uma verificação se nao der gps, nao ficar preso
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentPosition!, 8);
      _updateDistanceToLocals();
    });
  }

  void _updateDistanceToLocals() {
    if (_currentPosition != null) {
      for (var local in _locais) {
        final double distance = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            local.lat,
            local.lng);
        local.distance = distance.round();
      }
      _updateTop10NearbyLocals();
      setState(() {}); // atualizar a interface
    }
  }

  List<Local> _locaisTop10Nearby = [];
  void _updateTop10NearbyLocals() {
    _locaisTop10Nearby = (_locais
          ..sort((a, b) => a.distance.compareTo(b.distance)))
        .sublist(0, 10);
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
    return _locais.where((local) {
      bool isVisited = local.visitedByCurrentUser;
      if (_mostrarLocaisVisitados && isVisited) return true;
      if (_mostrarLocaisNaoVisitados && !isVisited) return true;
      return false;
    }).map((local) {
      return Marker(
        width: 80,
        height: 80,
        point: LatLng(local.lat, local.lng),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PoiScreen(poi: local, poiID: local.id),
              ),
            );
          },
          child: Icon(
            Icons.location_pin,
            size: 40,
            color: local.visitedByCurrentUser
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
                : ListView.builder(
                    itemCount: _locaisTop10Nearby.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        tileColor: Colors.white,
                        leading: Icon(
                          Icons.place,
                          color: _locaisTop10Nearby[index].visitedByCurrentUser
                              ? Colors.green.shade700
                              : Colors.greenAccent.shade700,
                        ),
                        title: Text(
                          _locaisTop10Nearby[index].name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          _formatDistance(_locaisTop10Nearby[index].distance),
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
                          _mapController.move(
                              LatLng(_locaisTop10Nearby[index].lat,
                                  _locaisTop10Nearby[index].lng),
                              13);
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
              initialCenter:
                  _currentPosition ?? const LatLng(40.631375, -8.659969), // UA
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
          ))
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
