
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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

