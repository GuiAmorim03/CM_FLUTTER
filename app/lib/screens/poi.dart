import 'package:app/main.dart';
import 'package:app/models/local.dart';
import 'package:app/models/userlocal.dart';
import 'package:app/screens/camera.dart';
import 'package:app/services/local_service.dart';
import 'package:flutter/material.dart';

// import '../models/locais.dart';

class PoiScreen extends StatefulWidget {
  const PoiScreen({super.key, required this.poi, required this.poiID});

  final Local poi;
  final int poiID;

  @override
  State<StatefulWidget> createState() {
    return _PoiScreenState();
  }
}

class _PoiScreenState extends State<PoiScreen> {
  String token = '';
  int userID = 0;
  Local? _poi;
  UserLocal? _userAndPoi;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getSession();
    _getPoi();
  }

  Future _getSession() async {
    final myAppState = context.findAncestorStateOfType<MyAppState>();
    token = myAppState!.getToken();
    userID = myAppState.getUserID();
  }

  Future<void> _getPoi() async {
    _poi = widget.poi;
    final localService = LocalService();
    _userAndPoi = await localService.fetchLocalInfoByUser(userID, widget.poiID);

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.green.shade100,
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              Container(
                  width: screenWidth * 0.6,
                  height: screenHeight * 0.5,
                  padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                  margin: const EdgeInsets.fromLTRB(10, 20, 0, 0),
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.green.shade700,
                          width: 5,
                        ),
                      ),
                      child: _userAndPoi!.imgUrl != null
                          ? Image.network(
                              _userAndPoi!.imgUrl ??
                                  'photos/no-photo.jpg', // nunca vai ter null, mas o flutter não sabe disso
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              "photos/no-photo.jpg",
                              fit: BoxFit.cover,
                            ))),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        _poi!.name,
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_poi!.visitedByCurrentUser) ...[
                      Text(
                        "Scanned on",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        _userAndPoi!.scanDate.toString().split(' ')[0],
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ] else
                      ElevatedButton(
                        onPressed: () async {
                          final imagePath = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CameraScreen(poiID: widget.poiID),
                            ),
                          );
                          if (imagePath != null && imagePath.isNotEmpty) {
                            setState(() {
                              _getPoi();
                              _poi!.visitedByCurrentUser = true;
                              // _poi["visited"] = {
                              //   "path": imagePath,
                              //   "date": DateTime.now()
                              //       .toIso8601String()
                              //       .split('T')[0]
                              // };
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
                ),
              )
            ]),
            const Padding(
                padding: EdgeInsets.all(20),
                child: Column(children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Friends Activity",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Text(
                    "TO DO",
                  )
                ]))
          ],
        ),
      ),
    );
  }
}
