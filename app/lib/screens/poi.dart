
import 'dart:io';

import 'package:app/screens/camera.dart';
import 'package:flutter/material.dart';

import '../models/locais.dart';

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
      body: 
        Container(
          width: double.infinity,
          color: Colors.green.shade100,
          child: Column(
            children: <Widget>[
                Row(
                  children: <Widget> [
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
                        child: poi.containsKey("visited") && poi["visited"]["path"] != null
                          ? poi["visited"]["path"].startsWith("photos")
                            ? Image.asset(
                                poi["visited"]["path"],
                                fit: BoxFit.cover,
                            )
                            : Image.file(
                              File(poi["visited"]["path"]),
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              "photos/no-photo.jpg",
                              fit: BoxFit.cover,
                          )
                      )
                    ),
                    Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            if (poi.containsKey("visited") && poi["visited"]["path"] != null) ...[
                              Text(
                                "Scanned on",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                "${poi["visited"]["date"]}",
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ]
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
                                    poi["visited"] = {"path": imagePath, "date": DateTime.now().toIso8601String().split('T')[0]};
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
                  ]
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
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
                    ]
                  )
                )
            ],
          ),
        ),
    );
  }
}

