class User {
  final int? id;
  final String fname;
  final String lname;
  final String username;
  final String password;
  final String gender;

  User(
      {this.id,
      required this.fname,
      required this.lname,
      required this.username,
      required this.gender,
      required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'] as int?,
        fname: json['fname'] ?? '',
        lname: json['lname'] ?? '',
        username: json['username'] ?? '',
        gender: json['gender'] ?? '',
        password: json['password'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'fname': fname,
      'lname': lname,
      'username': username,
      'password': password,
      'gender': gender,
    };
  }
}
