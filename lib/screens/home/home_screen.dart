import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = StreamController<QuerySnapshot>.broadcast();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _addFeedListener();
  }

  Future<Stream<QuerySnapshot>> _addFeedListener() async {
    //   Firestore db = Firestore.instance;
    //   Stream<QuerySnapshot> stream = db
    //       .collection("posts")
    //       .document(_idUsuarioLogado)
    //       .collection("posts")
    //       .snapshots();
    //
    //   stream.listen((dados) {
    //     _controller.add(dados);
    //   });
    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db.collection("posts").snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  Future<Null> refreshFeed() async {
    _refreshIndicatorKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _addFeedListener();
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
          Text("Carregando postagens"),
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

                    // return Expanded(
                    //   child: ListView.builder(
                    //       itemCount: querySnapshot.documents.length,
                    //       itemBuilder: (_, indice) {
                    //         List<DocumentSnapshot> posts =
                    //         querySnapshot.documents.toList();
                    //         DocumentSnapshot documentSnapshot = posts[indice];
                    //         Post post =
                    //         Post.fromDocumentSnapshot(
                    //             documentSnapshot);
                    //         return ItemPosts(
                    //           viagens: post,
                    //           onTapItem: () {
                    //             Navigator.push(
                    //                 context,
                    //                 MaterialPageRoute(
                    //                     builder: (context) => DetailScreen(
                    //                         post)));
                    //           },
                    //         );
                    //       }),
                    // );
                }
                return Container();
              },
            ),
          ],
        ),
        onRefresh: refreshFeed,
      ),
    );
  }
}
