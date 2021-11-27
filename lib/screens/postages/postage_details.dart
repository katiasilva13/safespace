import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safespace/models/postage.dart';
// import 'package:safespace/models/user_manager.dart';
import 'package:safespace/enumerator/permission.dart';

class PostageDetailsScreen extends StatefulWidget {
  Postage postage;
  String permission;

  PostageDetailsScreen(this.postage, this.permission);

  @override
  _PostageDetailsScreenState createState() => _PostageDetailsScreenState();
}

class _PostageDetailsScreenState extends State<PostageDetailsScreen> {
  Postage _postage;

  String _idLoggedUser;
  String _permission;

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

  _report() {
    Firestore db = Firestore.instance;
    Map<String, dynamic> updateData = {"reported": true, "hide": true};
    db
        .collection("posts")
        .document(_postage.id)
        .updateData(updateData)
        .then((_) {
      Navigator.of(context).pushReplacementNamed('/base');
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
      Navigator.of(context).pushReplacementNamed('/base');
    });
  }

  _delete() {
    Firestore db = Firestore.instance;
    Map<String, dynamic> updateData = {"deleted": true, "hide": true};
    db
        .collection("posts")
        .document(_postage.id)
        .updateData(updateData)
        .then((_) {
      Navigator.of(context).pushReplacementNamed('/base');
    });
  }

  _recoverLoggedUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _idLoggedUser = loggedUser.uid;
  }

  _initialize() async {
    _postage = widget.postage;
    _permission = widget.permission;

    await _recoverLoggedUserData();
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
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(
                height: 250,
                child: Carousel(
                  images: _getImageList(),
                  dotSize: 8,
                  dotBgColor: Colors.transparent,
                  dotColor: Colors.black,
                  autoplay: false,
                  dotIncreasedColor: Colors.greenAccent,
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Data de postagem",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${_postage.sendDate}",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
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
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 0, 100, 0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Center(
                          child: AutoSizeText(
                            "Denunciar",
                            maxLines: 2,
                            minFontSize: 10,
                            maxFontSize: 32,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                        ),
                      ),
                      onTap: () {
                        _report();
                      },
                    ),
                  ],
                ),
              ),
              if (PermissionHelper.isDev(_permission) ||
                  PermissionHelper.isMod(_permission)) ...[
                Container(
                  alignment: Alignment.center,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 0, 100, 0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(12),
                          child: Center(
                            child: AutoSizeText(
                              "Bloquear",
                              maxLines: 2,
                              minFontSize: 10,
                              maxFontSize: 32,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 22),
                            ),
                          ),
                        ),
                        onTap: () {
                          _block();
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                )
              ],
              // if (_postage.idUser.compareTo(_idLoggedUser) == 0) ...[
              //   Container(
              //     alignment: Alignment.center,
              //     child: Row(
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         GestureDetector(
              //           child: Container(
              //             decoration: BoxDecoration(
              //               color: Color.fromARGB(255, 0, 100, 0),
              //               borderRadius: BorderRadius.circular(12),
              //             ),
              //             padding: EdgeInsets.all(12),
              //             child: Center(
              //               child: AutoSizeText(
              //                 "Excluir",
              //                 maxLines: 2,
              //                 minFontSize: 10,
              //                 maxFontSize: 32,
              //                 textAlign: TextAlign.center,
              //                 style:
              //                     TextStyle(color: Colors.white, fontSize: 22),
              //               ),
              //             ),
              //           ),
              //           onTap: () {
              //             _delete();
              //           },
              //         ),
              //       ],
              //     ),
              //   ),
              //   SizedBox(
              //     height: 10,
              //   )
              // ]
            ],
          ),
        ],
      ),
    );
  }
}
