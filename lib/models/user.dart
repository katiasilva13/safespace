import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({this.email, this.password, this.name, this.id, this.nickname});

  User.fromDocument(DocumentSnapshot document) {
    id = document.documentID;
    name = document.data['name'] as String;
    email = document.data['email'] as String;
    permission = document.data['permission'] as String;
    nickname = document.data['nickname'] as String;
  }

  String id;
  String name;
  String email;
  String password;
  String confirmPassword;
  String permission;
  String nickname;

  DocumentReference get firestoreRef =>
      Firestore.instance.document('users/$id');

  Future<void> saveData() async {
    await firestoreRef.setData(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'permission': permission,
      'nickname': nickname,
    };
  }
}
