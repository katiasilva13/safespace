import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyPosts extends StatefulWidget {
  @override
  _MyPostsState createState() => _MyPostsState();
}

class _MyPostsState extends State<MyPosts> {
  String _idUsuarioLogado;

  final _controller = StreamController<QuerySnapshot>.broadcast();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  _recuperarDadosUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;
  }

  Future<Stream<QuerySnapshot>> _addMyPostsListener() async {
    await _recuperarDadosUsuarioLogado();

    Firestore db = Firestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("posts")
        .document(_idUsuarioLogado)
        .collection("posts")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  Future<Null> refreshMyPosts() async {
    _refreshIndicatorKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _addMyPostsListener();
    });

    return null;
  }

  @override
  void initState() {
    super.initState();
    _addMyPostsListener();
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
                }
                return Container();
              },
            ),
          ],
        ),
        onRefresh: refreshMyPosts,
      ),
    );
  }
}
