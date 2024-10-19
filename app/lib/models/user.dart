class User {
  final int id;
  final String username;
  final List<int> friends;

  User({
    required this.id,
    required this.username,
    required this.friends,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      friends: List<int>.from(json['friends']),
    );
  }

  @override
  String toString() {
    return 'User{id: $id, username: $username, friends: $friends}';
  }
}
