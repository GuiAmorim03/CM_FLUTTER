import 'package:app/main.dart';
import 'package:app/models/user.dart';
import 'package:app/screens/profile.dart';
import 'package:app/services/friends_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  bool isLoading = true;

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

    setState(() {
      isLoading = false;
    });
  }

  void _navigateToProfile(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(userID: user.id),
      ),
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share it with a friend!'),
          content: SizedBox(
            width: 200,
            height: 200,
            child: QrImageView(
              data: _currentUser.username,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(''),
            ),
          ],
        );
      },
    );
  }

  final TextEditingController usernameController = TextEditingController();
  void _showAddFriendDialog() {
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
            IconButton(
              icon: Icon(Icons.qr_code, color: Colors.green.shade800),
              onPressed: _scanQRCode,
            ),
            TextButton(
              onPressed: () {
                String username = usernameController.text.trim();
                _addFriend(username);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _scanQRCode() async {
    final String? username = await Navigator.push(
      context,
      MaterialPageRoute<String>(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Scan QR Code'),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
          ),
          body: MobileScanner(
            onDetect: (barcode) {
              final String? detectedUsername = barcode.barcodes[0].rawValue;
              if (detectedUsername != null) {
                Navigator.of(context).pop(detectedUsername);
              }
            },
          ),
        ),
      ),
    );

    if (username != null) {
      setState(() {
        usernameController.text = username;
      });
      await _addFriend(username);
    }
  }

  Future<void> _addFriend(String username) async {
    if (username.isNotEmpty) {
      final friendsService = FriendsService();
      User _friendToAdd =
          await friendsService.getUserDetailsByUsername(username);
      await friendsService.addFriend(userID, _friendToAdd.id);

      setState(() {
        _friendsList.add(_friendToAdd);
      });
      Navigator.of(context).pop();
    }
  }

  void _logout() {
    final myAppState = context.findAncestorStateOfType<MyAppState>();
    myAppState?.logout(); // Chama o método de logout
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _showQRCode, // Shows QR code
            backgroundColor: Colors.grey.shade700,
            foregroundColor: Colors.white,
            child: const Icon(Icons.qr_code),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _showAddFriendDialog,
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10), // Espaçamento entre os botões
          FloatingActionButton(
            onPressed: _logout, // Chama a função de logout
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            child: const Icon(Icons.logout),
          ),
        ],
      ),
    );
  }
}
