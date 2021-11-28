import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _idLoggedUser;
  String _name;
  String _photo;
  String _nickname;
  String _pronouns;
  String _block;
  String _bio;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idLoggedUser = usuarioLogado.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_idLoggedUser).get();

    Map<String, dynamic> dados = snapshot.data;

    setState(() {
      _nickname = dados["nickname"];
      _name = dados["name"];
      _bio = dados["bio"];
      _pronouns = dados["pronouns"];
    });

    if (dados["photo"] != null) {
      setState(() {
        _photo = dados["photo"];
      });
    }
  }

  Future<Null> refreshProfile() async {
    _refreshIndicatorKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _recuperarDadosUsuario();
    });

    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recuperarDadosUsuario();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(8, 10, 10, 8),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EditProfile()));
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 3,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    height: 200,
                    child: Row(
                      children: [
                        CircleAvatar(
                          maxRadius: 40,
                          backgroundColor: Colors.grey,
                          backgroundImage:
                              _photo != null ? NetworkImage(_photo) : null,
                        ),
                        Container(
                          height: 150,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(10, 1, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_name != null ? _name : '',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5, 5, 0, 3),
                                  child: Container(
                                    child: Text(
                                        (_nickname != null ? _nickname : '') +
                                            (_pronouns != null
                                                ? (' | ' + _pronouns)
                                                : ''),
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5, 5, 0, 3),
                                  child: Container(
                                    child: AutoSizeText(
                                        _bio != null ? _bio : '',
                                        style: TextStyle(fontSize: 18)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
        onRefresh: refreshProfile,
      ),
    );
  }
}
