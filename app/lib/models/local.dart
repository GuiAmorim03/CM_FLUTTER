// models/local.dart
class Local {
  final int id;
  final String name;
  final double lat;
  final double lng;
  int distance;

  Local({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    this.distance = 0,
  });

  factory Local.fromJson(Map<String, dynamic> json) {
    return Local(
      id: json['id'],
      name: json['name'],
      lat: json['latitude'],
      lng: json['longitude'],
    );
  }
}
