import 'package:app/models/local.dart';
import 'package:app/models/user.dart';
import 'package:app/services/api_url.dart';
import 'package:app/services/friends_service.dart';
import 'package:app/services/local_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userID});

  final int userID;
  // ignore: prefer_final_fields

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  List<Local>? _locals;
  List<Map<String, dynamic>>? _localsWithDetails;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    final userService = FriendsService();
    _user = await userService.getUserDetails(widget.userID);
    final localService = LocalService();
    _locals = await localService.fetchLocaisVisitados(widget.userID);

    _localsWithDetails = [];
    for (var local in _locals!) {
      final localDetails = await localService.fetchLocalInfoByUser(
        widget.userID,
        local.id,
      );

      _localsWithDetails!.add({
        'local': local,
        'details': localDetails,
      });
    }

    setState(() {
      isLoading = false;
    });
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
        title: Text(_user!.username),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Container(
          width: double.infinity,
          color: Colors.green.shade100,
          child: Center(
            child: _buildSwiper(),
          )),
    );
  }

  Widget _buildSwiper() {
    if (_locals == null || _locals!.isEmpty) {
      return const Text('No places visited');
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 600,
        enlargeCenterPage: true,
        enableInfiniteScroll: true,
        autoPlay: true,
      ),
      items: _localsWithDetails!.map((local) {
        return Builder(
          builder: (BuildContext context) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                children: [
                  Image.network(
                    '$apiUrl/${local['details'].imgUrl}',
                    fit: BoxFit.cover,
                    height: 400,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          local['local'].name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(local['local'].country),
                        const SizedBox(height: 5),
                        Text(
                            local['details'].scanDate.toString().split(' ')[0]),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
