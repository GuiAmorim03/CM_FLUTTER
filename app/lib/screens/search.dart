
import 'package:app/models/locais.dart';
import 'package:app/screens/poi.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  Map<String, List<Map<String, dynamic>>> groupedPlaces = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    groupedPlaces = _groupPlacesByCountry(locais);
  }

  Map<String, List<Map<String, dynamic>>> _groupPlacesByCountry (locals) {
    Map<String, List<Map<String, dynamic>>> groupedPlaces = {};
    locals.forEach((local) {
      if (groupedPlaces.containsKey(local['country'])) {
        groupedPlaces[local['country']]!.add(local);
      } else {
        groupedPlaces[local['country']] = [local];
      }
    });

    var sortedKeys = groupedPlaces.keys.toList()..sort();

    Map<String, List<Map<String, dynamic>>> sortedGroupedPlaces = {
      for (var country in sortedKeys) country: groupedPlaces[country]!
    };

    return sortedGroupedPlaces;
  }

  List<Map<String, dynamic>> _filterPlacesByName(searchText) {

    List<Map<String, dynamic>> filteredPlaces = [];
    for (var local in locais) {
      if (local['nome'].toLowerCase().contains(searchText)) {
        filteredPlaces.add(local);
      }
    }
    return filteredPlaces;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Places'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body:
        Column(
          children: [
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
                    groupedPlaces = _groupPlacesByCountry(_filterPlacesByName(searchText));
                  })
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: groupedPlaces.keys.length,
                itemBuilder: (context, index) {
                  String country = groupedPlaces.keys.elementAt(index);
                  List<Map<String, dynamic>> places = groupedPlaces[country]!;

                  return ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
                    title: Text(
                      country,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    backgroundColor: Colors.green.shade50,
                    children: places.map((place) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        title: Text(place['nome']),
                        subtitle: place.containsKey('visited') && place['visited'] != null 
                          ? Text('Visited at ${place['visited']['date']}')
                          : null,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PoiScreen(poiID: place["id"]),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            )
          ]
        )
    );
  }
}

