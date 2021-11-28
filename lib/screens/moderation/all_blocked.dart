import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:safespace/enumerator/permission.dart';
import 'package:safespace/models/postage.dart';
import 'package:safespace/screens/moderation/postage_details.dart';
import 'package:safespace/widget/postage_item.dart';

class AllBlocked extends StatefulWidget {
  @override
  _AllBlockedState createState() => _AllBlockedState();
}

class _AllBlockedState extends State<AllBlocked> {
  String _idLoggedUser;
  String _permission;

  final _controller = StreamController<QuerySnapshot>.broadcast();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _addPostagesListener();
  }

  _recoverUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _idLoggedUser = loggedUser.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_idLoggedUser).get();
    Map<String, dynamic> dados = snapshot.data;

    return dados["permission"];
  }

  Future<Stream<QuerySnapshot>> _addPostagesListener() async {
    _permission = await _recoverUserData();
    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("posts")
        .where('block', isEqualTo: true)
        .where('deleted', isEqualTo: false)
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  Future<Null> refreshPostages() async {
    _refreshIndicatorKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _addPostagesListener();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var loadingData = Center(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text("Carregando"),
          CircularProgressIndicator(),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.all(16),
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        child: Column(
          children: [
            StreamBuilder(
              stream: _controller.stream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return loadingData;
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    QuerySnapshot querySnapshot = snapshot.data;

                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      if (PermissionHelper.isDefault(_permission)) {
                        Navigator.of(context).pushReplacementNamed('/base');
                        return null;
                      }
                    });

                    if (querySnapshot.documents.length == 0) {
                      return Container(
                        padding: EdgeInsets.all(25),
                        child: Text(
                          "Nenhuma postagem",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      );
                    }

                    return Expanded(
                      child: ListView.builder(
                          itemCount: querySnapshot.documents.length,
                          itemBuilder: (_, indice) {
                            List<DocumentSnapshot> docs =
                                querySnapshot.documents.toList();
                            DocumentSnapshot documentSnapshot = docs[indice];
                            Postage postage =
                                Postage.fromDocumentSnapshot(documentSnapshot);
                            return PostageItem(
                              postages: postage,
                              onTapItem: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ModeratePostageDetailsScreen(
                                                postage, _permission)));
                              },
                            );
                          }),
                    );
                }
                return Container();
              },
            ),
          ],
        ),
        onRefresh: refreshPostages,
      ),
    );
  }
}
