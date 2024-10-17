// models/userlocal.dart

class UserLocal {
  final String? imgUrl;
  final DateTime? scanDate;

  UserLocal({
    required this.imgUrl,
    required this.scanDate,
  });

  factory UserLocal.fromJson(Map<String, dynamic> json) {
    return UserLocal(
      imgUrl: json['image_url'] != null ? json['image_url'] as String : null,
      scanDate:
          json['visited'] != null ? DateTime.parse(json['visited']) : null,
    );
  }

  @override
  String toString() {
    return 'UserLocal{imgUrl: $imgUrl, scanDate: $scanDate}';
  }
}
