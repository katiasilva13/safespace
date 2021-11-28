import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safespace/models/postage.dart';
import 'package:safespace/screens/postages/postage.dart';
import 'package:safespace/screens/postages/postage_details.dart';
import 'package:safespace/widget/postage_item.dart';

class MyPostages extends StatefulWidget {
  @override
  _MyPostagesState createState() => _MyPostagesState();
}

class _MyPostagesState extends State<MyPostages> {
  String _idLoggedUser;
  String _permission;

  final _controller = StreamController<QuerySnapshot>.broadcast();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  _recoverLoggedUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _idLoggedUser = loggedUser.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_idLoggedUser).get();
    Map<String, dynamic> dados = snapshot.data;

    return dados["permission"];
  }

  Future<Stream<QuerySnapshot>> _addMyPostagesListener() async {
    _permission = await _recoverLoggedUserData();
    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("my_posts")
        .document(_idLoggedUser)
        .collection("posts")
        .where('hide', whereIn: [null, false])
        .orderBy('sendDate', descending: true)
        .snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  Future<Null> refreshMyPostages() async {
    _refreshIndicatorKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _addMyPostagesListener();
    });
    return null;
  }

  @override
  void initState() {
    super.initState();
    _addMyPostagesListener();
  }

  @override
  Widget build(BuildContext context) {
    var loadingData = Center(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text("Carregando postagens"),
          CircularProgressIndicator(),
        ],
      ),
    );
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          foregroundColor: Colors.green,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PostageScreen()));
          },
        ),
        body: StreamBuilder(
          stream: _controller.stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return loadingData;
                break;
              case ConnectionState.active:
              case ConnectionState.done:
                if (snapshot.hasError) return Text("Erro ao carregar dados");

                QuerySnapshot querySnapshot = snapshot.data;
                return Container(
                  child: RefreshIndicator(
                    key: _refreshIndicatorKey,
                    child: ListView.builder(
                        itemCount: querySnapshot.documents.length,
                        itemBuilder: (_, indice) {
                          List<DocumentSnapshot> posts =
                              querySnapshot.documents.toList();
                          DocumentSnapshot documentSnapshot = posts[indice];
                          Postage postage =
                              Postage.fromDocumentSnapshot(documentSnapshot);
                          return PostageItem(
                            postages: postage,
                            onTapItem: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PostageDetailsScreen(
                                              postage, _permission)));
                            },
                          );
                        }),
                    onRefresh: refreshMyPostages,
                  ),
                );
            }
            return Container();
          },
        ));
  }
}
