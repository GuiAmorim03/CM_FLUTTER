
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

