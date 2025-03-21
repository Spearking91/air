import 'dart:convert';

class UserModel {
  String id;
  String username;
  String email;
  List<String>? devices;

  UserModel({required this.id, required this.username, required this.email, this.devices});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['id'],
        username: json['userna MM  Mme'],
        email: json['email'],
        devices: json['devices'] != null
            ? List<String>.from(json['devices'])
            : null);
  }

  Map<String, dynamic> toJson() {
    return {               
      'id': id,
      'email': email,
      'username': username,
      'devices': devices,
    };
  }

  @override
  String toString() {
    // return "{'username':$username, 'email':$email, 'devices': $devices}";
    return jsonEncode(toJson());
  }

  // UserModel noData() {
  //   return UserModel(username: '', email: '', devices: null);
  // }

  // UserModel copyWith({String? username, String? email, List<String>? devices}) {
  //   return UserModel(
  //       username: username ?? this.username, email: email ?? this.email);
  // }
}
