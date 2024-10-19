// services/local_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:app/models/userlocal.dart';
import 'package:app/services/api_url.dart';
import 'package:http/http.dart' as http;
import '../models/local.dart';

class LocalService {
  Future<List<Local>> fetchLocais() async {
    final url = Uri.parse('$apiUrl/locals/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Local> locais = data.map((json) => Local.fromJson(json)).toList();
      return locais;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load locais');
    }
  }

  Future<Map<String, List<Local>>> fetchLocaisGroupedByCountry(
      searchText) async {
    final url = Uri.parse('$apiUrl/locals/country/?search=$searchText');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      Map<String, List<Local>> locais = data.map((country, localsList) {
        return MapEntry(
          country,
          List<Local>.from(
            localsList.map((localJson) => Local.fromJson(localJson)),
          ),
        );
      });
      return locais;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load locais');
    }
  }

  Future<List<Local>> fetchLocaisVisitados(int userID) async {
    final url = Uri.parse('$apiUrl/locals/$userID/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<Local> locais = data.map((json) => Local.fromJson(json)).toList();
      return locais;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load locais');
    }
  }

  Future<UserLocal> fetchLocalInfoByUser(int userID, int localID) async {
    final url = Uri.parse('$apiUrl/locals/$userID/$localID');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return UserLocal.fromJson(data);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load local');
    }
  }

  Future<String> savePhoto(File image, int userID, int localID) async {
    final url = Uri.parse('$apiUrl/upload-image/');
    final request = http.MultipartRequest('POST', url);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
      ),
    );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await http.Response.fromStream(response);
      final data = json.decode(responseBody.body);

      // save url in database
      await savePhotoInDb(userID, localID, data['image_url']);

      return data['image_url'];
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<void> savePhotoInDb(int userID, int localID, String imageUrl) async {
    final url = Uri.parse('$apiUrl/userlocal/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user_id': userID,
        'local_id': localID,
        'image_url': imageUrl,
        'visited': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save photo in database');
    }
  }
}
