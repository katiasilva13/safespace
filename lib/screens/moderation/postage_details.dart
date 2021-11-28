import 'dart:ui';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safespace/models/postage.dart';
import 'package:intl/intl.dart';
import 'package:safespace/models/user.dart';

class ModeratePostageDetailsScreen extends StatefulWidget {
  Postage postage;
  String permission;

  ModeratePostageDetailsScreen(this.postage, this.permission);

  @override
  _ModeratePostageDetailsScreenState createState() =>
      _ModeratePostageDetailsScreenState();
}

class _ModeratePostageDetailsScreenState
    extends State<ModeratePostageDetailsScreen> {
  Postage _postage;
  User _author = User();

  String _idLoggedUser;
  String _permission;
  int _button;

  List<Widget> _getImageList() {
    List<String> imageUrlList = _postage.images;

    return imageUrlList.map((url) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          image:
              DecorationImage(image: NetworkImage(url), fit: BoxFit.fitWidth),
        ),
      );
    }).toList();
  }

  _revertReport() {
    Firestore db = Firestore.instance;
    Map<String, dynamic> updateData = {"reported": false, "hide": false};
    db
        .collection("posts")
        .document(_postage.id)
        .updateData(updateData)
        .then((_) {
      Navigator.of(context).pushReplacementNamed('/reported-posts');
    });
  }

  _block() {
    Firestore db = Firestore.instance;
    Map<String, dynamic> updateData = {"block": true, "hide": true};
    db
        .collection("posts")
        .document(_postage.id)
        .updateData(updateData)
        .then((_) {
      Navigator.of(context).pushReplacementNamed('/blocked-posts');
    });
  }

  _unblock() {
    Firestore db = Firestore.instance;
    Map<String, dynamic> updateData = {"block": false, "hide": false};
    db
        .collection("posts")
        .document(_postage.id)
        .updateData(updateData)
        .then((_) {
      Navigator.of(context).pushReplacementNamed('/blocked-posts');
    });
  }

  _blockUser() {
    Firestore db = Firestore.instance;
    Map<String, dynamic> updateData = {"block": true, "hide": true};
    db
        .collection("users")
        .document(_author.id)
        .updateData(updateData)
        .then((_) {
      Navigator.of(context).pushReplacementNamed('/blocked-posts');
    });
  }

  _unblockUser() {
    Firestore db = Firestore.instance;
    Map<String, dynamic> updateData = {"unblock": true, "hide": true};
    db
        .collection("users")
        .document(_author.id)
        .updateData(updateData)
        .then((_) {
      Navigator.of(context).pushReplacementNamed('/blocked-posts');
    });
  }

  _recoverLoggedUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _idLoggedUser = loggedUser.uid;
  }

  _getPostAuthor() async {
    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_postage.idUser).get();

    Map<String, dynamic> dados = snapshot.data;

    // setState(() {
      _author.id = dados["id"];
      _author.name = dados["name"];
      _author.nickname = dados["nickname"];
      _author.block = dados["block"];
    // });

    if (dados["photo"] != null) {
      // setState(() {
        _author.photo = dados["photo"];
      // });
    }
  }

  _executeAction() {
    switch (_button) {
      case 0:
        _revertReport();
        break;
      case 1:
        _block();
        break;
      case 2:
        _unblock();
        break;
      case 3:
        _blockUser();
        break;
      case 4:
        _unblockUser();
        break;
    }
  }

  _initialize() async {
    _postage = widget.postage;
    _permission = widget.permission;
    await _recoverLoggedUserData();
    await _getPostAuthor();
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Postagem"),
        backgroundColor: Colors.deepPurple,
        actions: [
          PopupMenuButton(
              elevation: 20,
              enabled: true,
              onSelected: (value) {
                setState(() {
                  _button = value;
                  _executeAction();
                });
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("Recusar denúncia"),
                      value: 0,
                      enabled: (_postage.reported),
                    ),
                    PopupMenuItem(
                      child: Text("Bloquear post"),
                      value: 1,
                      enabled: (!_postage.block),
                    ),
                    PopupMenuItem(
                      child: Text("Desbloquear post"),
                      value: 2,
                      enabled: (_postage.block),
                    ),
                    PopupMenuItem(
                      child: Text("Bloquear usuário"),
                      value: 3,
                      enabled: (!_author.block),
                    ),
                    PopupMenuItem(
                      child: Text("Desbloquear usuário"),
                      value: 4,
                      enabled: (_author.block),
                    )
                  ])
        ],
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(
                height: 80,
                child: Row(
                  children: [
                    CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage: _author.photo != null
                          ? NetworkImage(_author.photo)
                          : null,
                    ),
                    Container(
                      height: 150,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10, 1, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(5, 25, 0, 3),
                              child: Container(
                                child: Text(
                                    _author.name != null
                                        ? _author.name
                                        : '',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(5, 1, 0, 3),
                              child: Container(
                                child: Text(
                                    _author.nickname != null
                                        ? _author.nickname
                                        : '',
                                    style: TextStyle(fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: (_postage.images.first.length > 0) ? 250 : 0,
                child: Carousel(
                  images: _getImageList(),
                  dotSize: 8,
                  dotBgColor: Colors.transparent,
                  dotColor: Colors.black,
                  autoplay: false,
                  dotIncreasedColor: Colors.black,
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Post",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${_postage.message}",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
                    Text(
                      "Data de postagem",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${(DateFormat('dd/MM/yyyy H:m:s').format(_postage.sendDate))}",
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
