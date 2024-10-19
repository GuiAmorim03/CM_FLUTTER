import 'dart:convert';
import 'package:app/models/user.dart';
import 'package:app/services/api_url.dart';
import 'package:http/http.dart' as http;

class FriendsService {
  Future<User> getUserDetails(int userID) async {
    final url = Uri.parse('$apiUrl/users/$userID/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<User> getUserDetailsByUsername(String username) async {
    final url = Uri.parse('$apiUrl/users/username/$username');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load user details');
    }
  }

  Future<void> addFriend(int userID, int friendID) async {
    final url = Uri.parse('$apiUrl/users/friends/$userID/$friendID/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add friend');
    }
  }
}
