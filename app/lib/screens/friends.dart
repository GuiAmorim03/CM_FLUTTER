import 'package:app/main.dart';
import 'package:app/models/user.dart';
import 'package:app/screens/profile.dart';
import 'package:app/services/friends_service.dart';
import 'package:flutter/material.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  String token = '';
  int userID = 0;

  User _currentUser = User(id: 0, username: '', friends: []);
  // ignore: prefer_final_fields
  List<User> _friendsList = [];

  @override
  void initState() {
    super.initState();
    _getSession();
    _getFriends();
  }

  Future _getSession() async {
    final myAppState = context.findAncestorStateOfType<MyAppState>();
    token = myAppState!.getToken();
    userID = myAppState.getUserID();
  }

  Future<void> _getFriends() async {
    final friendsService = FriendsService();
    _currentUser = await friendsService.getUserDetails(userID);
    // ignore: avoid_function_literals_in_foreach_calls
    _currentUser.friends.forEach(
      (friendID) async {
        User friend = await friendsService.getUserDetails(friendID);
        setState(() {
          _friendsList.add(friend);
        });
      },
    );
  }

  void _navigateToProfile(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userID: user.id),
      ),
    );
  }

  void _showAddFriendDialog() {
    final TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Friend'),
          content: TextField(
            controller: usernameController,
            decoration: const InputDecoration(hintText: 'Enter username'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String username = usernameController.text.trim();
                _addFriend(username);
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo sem adicionar
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addFriend(String username) async {
    if (username.isNotEmpty) {
      final friendsService = FriendsService();
      User _friendToAdd =
          await friendsService.getUserDetailsByUsername(username);
      print(username);
      print(_friendToAdd);
      await friendsService.addFriend(userID, _friendToAdd.id);

      setState(() {
        _friendsList.add(_friendToAdd);
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              'Me (${_currentUser.username})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () => _navigateToProfile(_currentUser),
          ),
          const Divider(),
          ..._friendsList.map((friend) {
            return ListTile(
              title: Text(friend.username),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _navigateToProfile(friend),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
