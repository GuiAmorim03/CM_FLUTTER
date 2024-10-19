// models/local.dart
class Local {
  final int id;
  final String name;
  final String country;
  final double lat;
  final double lng;
  int distance;
  bool visitedByCurrentUser;

  Local({
    required this.id,
    required this.name,
    required this.country,
    required this.lat,
    required this.lng,
    this.distance = 0,
    this.visitedByCurrentUser = false,
  });

  factory Local.fromJson(Map<String, dynamic> json) {
    return Local(
      id: json['id'],
      name: json['name'],
      country: json['country'],
      lat: json['latitude'],
      lng: json['longitude'],
    );
  }

  @override
  String toString() {
    return 'Local{id: $id, name: $name, country: $country, lat: $lat, lng: $lng}';
  }
}
