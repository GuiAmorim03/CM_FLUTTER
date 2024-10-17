// services/login_service.dart
import 'package:app/services/api_url.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class LoginService {
  Future<Response> login(String username, String password) async {
    final url = Uri.parse('$apiUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
      },
    );

    return response;
  }
}
