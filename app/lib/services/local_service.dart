// services/local_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/local.dart';

class LocalService {
  final String _baseUrl = 'http://192.168.1.90:8000';

  Future<List<Local>> fetchLocais() async {
    final url = Uri.parse('$_baseUrl/locals');
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
}
