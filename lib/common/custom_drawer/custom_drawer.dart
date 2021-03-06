import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safespace/common/custom_drawer/custom_drawer_header.dart';
import 'package:safespace/common/custom_drawer/drawer_tile.dart';
import 'package:safespace/enumerator/permission.dart';
import 'package:safespace/models/user/user_manager.dart';

class CustomDrawer extends StatelessWidget {
  String _idLoggedUser;
  String _permission;

  _recoverUserData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser loggedUser = await auth.currentUser();
    _idLoggedUser = loggedUser.uid;

    Firestore db = Firestore.instance;
    DocumentSnapshot snapshot =
        await db.collection("users").document(_idLoggedUser).get();

    Map<String, dynamic> dados = snapshot.data;

    _permission = dados["permission"];

    print(_permission);
  }

  _initialize() async {
    await _recoverUserData();
  }

  void initState() {
    _initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 203, 236, 241),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
          ),
          ListView(
            children: <Widget>[
              CustomDrawerHeader(),
              const Divider(),
              DrawerTile(
                iconData: Icons.home,
                title: 'Início',
                page: 0,
              ),
              Consumer<UserManager>(
                builder: (_, userManager, __) {
                  return Column(
                    children: <Widget>[
                      const Divider(),
                      DrawerTile(
                        iconData: Icons.feed,
                        title: 'Minhas Postagens',
                        page: 1,
                      ),
                      DrawerTile(
                        iconData: Icons.admin_panel_settings,
                        title: 'Perfil',
                        page: 2,
                      ),
                      DrawerTile(
                        iconData: Icons.report_rounded,
                        title: 'Moderação: Denúncias',
                        page: 3,
                      ),
                      DrawerTile(
                        iconData: Icons.block,
                        title: 'Moderação: Bloqueados',
                        page: 4,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
