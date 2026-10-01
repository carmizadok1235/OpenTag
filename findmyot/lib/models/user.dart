

class User {
  final int id;
  String username;
  String appleid;

  User({required this.id, required this.username, required this.appleid});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"] as int,
      username: json["username"] as String,
      appleid: json["appleid"] as String
    );
  }
}


class UserCreate {
  final String username;
  final String password;
  final String appleid;
  final String appleidPassword;

  UserCreate({required this.username, required this.password, required this.appleid, required this.appleidPassword});
}
