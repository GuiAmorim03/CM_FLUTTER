// services/login_service.dart
import 'package:app/services/api_url.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class LoginService {
  Future<Response> login(String username, String password) async {
    print("dentro do service");
    print("username: $username");
    print("password: $password");
    final url = Uri.parse('$apiUrl/login');
    print(url);
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
