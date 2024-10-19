import 'package:app/models/local.dart';
import 'package:app/screens/poi.dart';
import 'package:app/services/local_service.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Map<String, List<Local>> groupedPlaces = {};

  final TextEditingController _searchController = TextEditingController();

  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _groupPlacesByCountry('');
  }

  Future<void> _groupPlacesByCountry(searchText) async {
    final localService = LocalService();
    groupedPlaces = await localService.fetchLocaisGroupedByCountry(searchText);

    setState(() {
      isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Search Places'),
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by place name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (searchText) => {
                setState(() {
                  _groupPlacesByCountry(searchText);
                })
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: groupedPlaces.keys.length,
              itemBuilder: (context, index) {
                String country = groupedPlaces.keys.elementAt(index);
                List<Local> places = groupedPlaces[country]!;

                return ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                  title: Text(
                    country,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  backgroundColor: Colors.green.shade50,
                  children: places.map((place) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
                      title: Text(place.name),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              PoiScreen(poi: place, poiID: place.id),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          )
        ]));
  }
}
